import 'dart:async';
import 'dart:io';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/session/view/generic_session_page.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:open_app_file/open_app_file.dart';

import '../../../shared/ui/navigation_shell.dart';
import '../../../shared/ui/table_view.dart';
import '../../../shared/utils/commons.dart';
import '../provider/session.provider.dart';

enum _SftpColumn {
  name(
    permanent: true,
    valueBuilder: _buildName,
    prefixBuilder: _buildNamePrefix,
  ),
  modified(
    valueBuilder: _buildModified,
    sortableValueBuilder: _buildModifiedSortable,
  ),
  size(valueBuilder: _buildSize, sortableValueBuilder: _buildSizeSortable),
  kind(valueBuilder: _buildKind),
  accessed(
    valueBuilder: _buildAccessed,
    sortableValueBuilder: _buildAccessedSortable,
  ),
  permissions(valueBuilder: _buildPermissions);

  /// Whether this column can be hidden in the context menu
  final bool permanent;
  final String Function(SftpName) valueBuilder;
  final int Function(SftpName)? sortableValueBuilder;
  final Widget Function(SftpName)? prefixBuilder;

  const _SftpColumn({
    this.permanent = false,
    required this.valueBuilder,
    this.sortableValueBuilder,
    this.prefixBuilder,
  });

  String getDisplayName(BuildContext context) {
    return switch (this) {
      .name => 'Name',
      .modified => 'Last Modified',
      .size => 'Size',
      .kind => 'Kind',
      .accessed => 'Last Accessed',
      .permissions => 'Permissions',
    };
  }

  static String _buildName(SftpName file) => file.filename;
  static Widget _buildNamePrefix(SftpName file) {
    if (file.attr.isDirectory) {
      return Icon(LucideIcons.folder);
    }
    if (file.attr.isSymbolicLink) {
      return Icon(LucideIcons.fileInput);
    }
    return Icon(LucideIcons.file);
  }

  static String _buildModified(SftpName file) =>
      _buildTimestamp(file.attr.modifyTime);

  static int _buildModifiedSortable(SftpName file) => file.attr.modifyTime ?? 0;

  static String _buildSize(SftpName file) {
    if (file.attr.isDirectory) {
      return '--';
    }
    return TextUtils.formatBytes(file.attr.size) ?? '--';
  }

  static int _buildSizeSortable(SftpName file) => file.attr.size ?? 0;

  static String _buildKind(SftpName file) {
    if (file.attr.isDirectory) {
      return 'Folder';
    }
    if (file.attr.isSymbolicLink) {
      return 'Symlink';
    }
    return 'File';
  }

  static String _buildAccessed(SftpName file) =>
      _buildTimestamp(file.attr.accessTime);

  static int _buildAccessedSortable(SftpName file) => file.attr.accessTime ?? 0;

  static String _buildPermissions(SftpName file) {
    final perms = file.attr.mode;
    if (perms == null) return '--';

    final isDir = file.attr.isDirectory;
    return (StringBuffer()
          ..write(isDir ? 'd' : '-')
          ..write(perms.userRead ? 'r' : '-')
          ..write(perms.userWrite ? 'w' : '-')
          ..write(perms.userExecute ? 'x' : '-')
          ..write(perms.groupRead ? 'r' : '-')
          ..write(perms.groupWrite ? 'w' : '-')
          ..write(perms.groupExecute ? 'x' : '-')
          ..write(perms.otherRead ? 'r' : '-')
          ..write(perms.otherWrite ? 'w' : '-')
          ..write(perms.otherExecute ? 'x' : '-'))
        .toString();
  }

  static String _buildTimestamp(int? timestamp) {
    if (timestamp == null) return '--';
    return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000).toString();
  }
}

class _SftpDragData {
  final String sessionId;
  final Map<String, _FileData> files;

  const _SftpDragData({required this.sessionId, required this.files});
}

class _FileData {
  /// The file path on the remote host
  final String path;

  /// Temp path on the local system
  final String? tempPath;

  const _FileData({required this.path, this.tempPath});

  String get fileName => path.split('/').last;

  String getFileId(String sessionId) => '$sessionId:$path';

  _FileData copyWith({String? path, String? tempPath}) {
    return _FileData(
      path: path ?? this.path,
      tempPath: tempPath ?? this.tempPath,
    );
  }
}

class FileProgressData {
  final int currentBytes;
  final int totalBytes;
  final String? error;

  const FileProgressData({
    required this.currentBytes,
    required this.totalBytes,
    this.error,
  });
  const FileProgressData.completed({this.totalBytes = 1})
    : currentBytes = totalBytes,
      error = null;
  const FileProgressData.zero()
    : currentBytes = 0,
      totalBytes = 1,
      error = null;
  const FileProgressData.error(this.error) : currentBytes = 0, totalBytes = 1;

  double get progress => totalBytes == 0 ? 0 : currentBytes / totalBytes;

  FileProgressData copyWith({
    int? currentBytes,
    int? totalBytes,
    String? error,
  }) {
    return FileProgressData(
      currentBytes: currentBytes ?? this.currentBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      error: error ?? this.error,
    );
  }
}

const _ignoredFilenames = {'.'};
const _ignoredSelectableFilenames = {'.', '..'};

class SftpSessionPage extends StatefulHookConsumerWidget {
  final String sessionId;

  const SftpSessionPage({super.key, required this.sessionId});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SftpSessionPageState();
}

class _SftpSessionPageState extends ConsumerState<SftpSessionPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final session = ref
        .watch(sessionProvider.notifier)
        .getSessionById(widget.sessionId)!;

    final isLoading = useState(true);

    final navigateBackBuffer = useState<List<String>?>(null);

    final currentDirectory = useState<List<String>?>([]);
    final currentFiles = useState<List<SftpName>?>(null);

    final selectedFilesIds = useState<Set<String>>({});

    final queuedFiles = useState<Map<String, _FileData>>({});
    final queuedFilesProgress =
        useState<Map<String, ValueNotifier<FileProgressData>>>({});

    // modified file data that needs to be confirmed by the user before writing
    final modifiedFiles = useState<Map<String, _FileData>>({});

    final tempDir = useMemoized(
      () => Directory.systemTemp.createTempSync('cliq_sftp_${session.id}'),
    );

    final visibleColumns = useState<Set<_SftpColumn>>({
      .name,
      .modified,
      .size,
      .kind,
    });
    final sortColumn = useState<(_SftpColumn, bool)?>(null);
    final showHiddenFiles = useStore(.sftpShowHiddenFiles);

    final rotation = useAnimationController(
      duration: const Duration(seconds: 2),
    );

    retrySession({bool skipHostKeyVerification = false}) {
      ref
          .read(sessionProvider.notifier)
          .resetSession(
            NavigationShell.of(context),
            session.id,
            skipHostKeyVerification: skipHostKeyVerification,
          );
    }

    // open SFTP connection when terminal controller is set
    useEffect(() {
      Future<void> openSftp(ConnectionFull connection) async {
        isLoading.value = true;

        final client =
            session.client ??
            await ref
                .read(sessionProvider.notifier)
                .createSSHClient(session, connection);

        if (client == null || !mounted) {
          return;
        }

        final sftpSession = await ref
            .read(sessionProvider.notifier)
            .spawnSftp(session.id, client);

        currentDirectory.value = (await sftpSession.absolute('.')).split('/');

        isLoading.value = false;
      }

      final connectionFull = ref
          .read(connectionProvider.notifier)
          .findById(session.connection.id);

      if (connectionFull != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          openSftp(connectionFull);
        });
      }

      return null;
    }, []);

    // fetch files in current directory
    useEffect(() {
      if (session.sftpClient == null ||
          currentDirectory.value == null ||
          isLoading.value) {
        return null;
      }

      fetch() async {
        isLoading.value = true;

        try {
          final path = currentDirectory.value!.join('/');

          currentFiles.value =
              (await session.sftpClient!.listdir(path.isEmpty ? '/' : path))
                  .where((file) => !_ignoredFilenames.contains(file.filename))
                  .toList();
        } on SftpStatusError catch (e) {
          if (!context.mounted) return;

          Commons.showToast(
            'Failed to open: ${e.message}',
            prefix: Icon(
              LucideIcons.folderLock,
              size: 20,
              color: context.theme.colors.destructive,
            ),
            variant: .destructive,
          );

          // remove last path part and try again
          if (currentDirectory.value!.isNotEmpty) {
            final current = [...currentDirectory.value!];
            current.removeLast();
            currentDirectory.value = current;
          }
        } finally {
          isLoading.value = false;
        }
      }

      fetch();
      return null;
    }, [currentDirectory.value]);

    useEffect(() {
      if (queuedFiles.value.isEmpty) {
        rotation
          ..stop()
          ..reset();
      } else {
        rotation.repeat();
      }
      return null;
    }, [queuedFiles.value]);

    getFileIdFromSftpName(SftpName file) {
      return '${session.id}:${[...?currentDirectory.value, file.filename].join('/')}';
    }

    // helper for preventing certain actions while loading
    onAction(VoidCallback func) => isLoading.value ? null : func;

    setQueuedFileProgress(String id, FileProgressData? data) {
      if (data == null || data.progress >= 1) {
        queuedFilesProgress.value[id]?.dispose();
        queuedFilesProgress.value = {...queuedFilesProgress.value..remove(id)};
        // also remove queued file
        queuedFiles.value = {...queuedFiles.value..remove(id)};
        return;
      }

      if (queuedFilesProgress.value.containsKey(id)) {
        queuedFilesProgress.value[id]!.value = data;
      } else {
        queuedFilesProgress.value = {
          ...queuedFilesProgress.value,
          id: ValueNotifier(data),
        };
      }
    }

    addQueuedFile(String id, _FileData file) {
      setQueuedFileProgress(id, .zero());
      queuedFiles.value = {...queuedFiles.value, id: file};
    }

    onFolderPress(SftpName file) async {
      if (!file.attr.isDirectory || file.filename.isEmpty) {
        return;
      }
      isLoading.value = true;
      final path =
          await session.sftpClient!.absolute(
              [...?currentDirectory.value, file.filename].join('/'),
            )
            ..trim();

      selectedFilesIds.value = {};
      currentDirectory.value = path == '/' ? [''] : path.split('/');
      navigateBackBuffer.value = null;
      isLoading.value = false;
    }

    onFilePress(SftpName file, String id) async {
      if (file.filename.isEmpty) {
        return;
      }

      final fullPath = [...?currentDirectory.value, file.filename].join('/');
      final fullName =
          '${tempDir.path}${Platform.pathSeparator}${file.filename}';
      File tempFile = File(fullName);

      addQueuedFile(id, _FileData(path: tempFile.path));

      attemptOpenAndWatch(File file) async {
        // open with default app
        final result = await OpenAppFile.open(file.path);

        if (result.type == .noAppToOpen || result.type == .error) {
          // add .txt extension and try again
          final withExtension = File('${file.path}.txt');
          await file.rename(withExtension.path);

          final fallbackResult = await OpenAppFile.open(withExtension.path);
          if (fallbackResult.type == .done) {
            file = withExtension;

            // update temp file name in state
            // TODO:?
          }
        }

        final originalContent = await file.readAsBytes();

        file.parent.watch().listen((event) async {
          if (event.path != tempFile.path) return;
          if (event.type == FileSystemEvent.create ||
              event.type == FileSystemEvent.modify) {
            await Future.delayed(const Duration(milliseconds: 100));
            try {
              final newContent = await File(event.path).readAsBytes();
              if (listEquals(newContent, originalContent)) {
                modifiedFiles.value = {...modifiedFiles.value..remove(id)};
              } else {
                modifiedFiles.value = {
                  ...modifiedFiles.value,
                  id: _FileData(path: fullPath, tempPath: tempFile.path),
                };
              }
            } catch (_) {}
          }
        });
      }

      ref
          .read(sessionProvider.notifier)
          .transferSftp(
            source: session,
            sourcePath: fullPath,
            localPath: tempFile.path,
          )
          .listen((p) => setQueuedFileProgress(id, p))
          .onDone(() async {
            setQueuedFileProgress(id, null);
            await attemptOpenAndWatch(tempFile);
          });
    }

    onSymlinkPress(SftpName file, String id) async {
      if (!file.attr.isSymbolicLink || file.filename.isEmpty) return;
      isLoading.value = true;

      final symlinkPath = [...?currentDirectory.value, file.filename].join('/');
      final targetAttr = await session.sftpClient!.stat(symlinkPath);

      if (targetAttr.isDirectory) {
        final absolutePath = await session.sftpClient!.absolute(symlinkPath);
        currentDirectory.value = absolutePath.split('/');
        navigateBackBuffer.value = null;
      } else {
        await onFilePress(file, id);
      }

      isLoading.value = false;
    }

    cleanupModified(SftpName file, String id) {
      final modifiedFile = modifiedFiles.value[id];
      if (modifiedFile == null) return;

      // delete local file
      if (modifiedFile.tempPath != null) {
        final tempFile = File(modifiedFile.tempPath!);
        if (tempFile.existsSync()) {
          debugPrint('Deleting temp file: ${tempFile.path}');
          tempFile.deleteSync();
        }
      }

      modifiedFiles.value = {...modifiedFiles.value..remove(id)};
    }

    uploadModified(SftpName file, String id) {
      final modifiedFile = modifiedFiles.value[id];
      if (modifiedFile == null) return;
      debugPrint(
        'Uploading modified file: ${modifiedFile.tempPath} to ${modifiedFile.path}',
      );

      addQueuedFile(id, _FileData(path: modifiedFile.path));
      ref
          .read(sessionProvider.notifier)
          .transferSftp(
            localPath: modifiedFiles.value[id]!.tempPath!,
            destination: session,
            destinationPath: [
              ...?currentDirectory.value,
              file.filename,
            ].join('/'),
          )
          .listen((p) => setQueuedFileProgress(id, p))
          .onDone(() {
            cleanupModified(file, id);
            setQueuedFileProgress(id, null);

            // refresh directory
            currentDirectory.value = [...?currentDirectory.value];
          });
    }

    isHiddenFile(SftpName file) {
      if (file.filename.isEmpty || file.filename == '..') return false;
      return file.filename.startsWith('.');
    }

    buildTableHeader(_SftpColumn col) {
      final isSorted = sortColumn.value?.$1 == col;
      final isAscending = sortColumn.value?.$2 ?? true;

      return TableViewCell(
        child: Row(
          spacing: 8,
          children: [
            Flexible(
              child: Text(
                col.getDisplayName(context),
                softWrap: false,
                overflow: .fade,
              ),
            ),
            if (isSorted)
              Icon(
                isAscending ? LucideIcons.arrowUp : LucideIcons.arrowDown,
                size: 12,
              ),
          ],
        ),
      );
    }

    return GenericSessionPage(
      session: session,
      isConnected: session.isConnected && currentDirectory.value != null,
      isLikelyLoading: session.isLikelyLoading,
      onRetry: retrySession,
      child: SizedBox.expand(
        child: Column(
          spacing: 8,
          children: [
            Padding(
              padding: const .only(top: 8, left: 8, right: 8),
              child: Row(
                spacing: 8,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      // TODO implement
                      FTooltip(
                        tipBuilder: (_, _) => Text('Navigate back'),
                        child: FButton.icon(
                          variant: .outline,
                          onPress:
                              currentDirectory.value == null ||
                                  currentDirectory.value!.length <= 1
                              ? null
                              : onAction(() {
                                  // remove last part of current directory
                                  final current = [...currentDirectory.value!];
                                  final removed = current.removeLast();
                                  navigateBackBuffer.value = [
                                    ...?navigateBackBuffer.value,
                                    removed,
                                  ];
                                  currentDirectory.value = current;
                                }),
                          child: Icon(LucideIcons.arrowLeft),
                        ),
                      ),
                      FTooltip(
                        tipBuilder: (_, _) => Text('Navigate forward'),
                        child: FButton.icon(
                          variant: .outline,
                          onPress:
                              navigateBackBuffer.value == null ||
                                  navigateBackBuffer.value!.isEmpty
                              ? null
                              : onAction(() {
                                  final current = [
                                    ...?currentDirectory.value,
                                    navigateBackBuffer.value!.removeLast(),
                                  ];
                                  currentDirectory.value = current;
                                }),
                          child: Icon(LucideIcons.arrowRight),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: .horizontal,
                      child: FBreadcrumb(
                        children: [
                          for (final part in currentDirectory.value!)
                            // if last part
                            if (isLoading.value &&
                                part == currentDirectory.value!.last)
                              Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: FCircularProgress(),
                              )
                            else
                              FBreadcrumbItem(
                                onPress: onAction(() {
                                  final index = currentDirectory.value!.indexOf(
                                    part,
                                  );
                                  currentDirectory.value = currentDirectory
                                      .value!
                                      .sublist(0, index + 1);
                                  navigateBackBuffer.value = null;
                                }),
                                child: Text(part.isEmpty ? '/' : part),
                              ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      FPopoverMenu(
                        menu: [
                          .group(
                            children: [
                              .item(
                                title: Text('Refresh'),
                                prefix: Icon(LucideIcons.refreshCw),
                                onPress: onAction(() {
                                  // trigger refetch by setting current directory to itself
                                  currentDirectory.value = [
                                    ...?currentDirectory.value,
                                  ];
                                }),
                              ),
                            ],
                          ),
                          .group(
                            children: [
                              for (final col in _SftpColumn.values)
                                if (!col.permanent)
                                  .item(
                                    title: Text(col.getDisplayName(context)),
                                    prefix: visibleColumns.value.contains(col)
                                        ? Icon(LucideIcons.check)
                                        : SizedBox(width: 16),
                                    onPress: () {
                                      if (visibleColumns.value.contains(col)) {
                                        visibleColumns.value = {
                                          ...visibleColumns.value..remove(col),
                                        };
                                      } else {
                                        visibleColumns.value = {
                                          ...visibleColumns.value..add(col),
                                        };
                                      }
                                    },
                                  ),
                            ],
                          ),
                          .group(
                            children: [
                              .item(
                                title: Text('Hidden files'),
                                prefix: showHiddenFiles.value
                                    ? Icon(LucideIcons.check)
                                    : SizedBox(width: 16),
                                onPress: () => StoreKey.sftpShowHiddenFiles
                                    .write(!showHiddenFiles.value),
                              ),
                            ],
                          ),
                        ],
                        builder: (_, controller, _) {
                          return FButton.icon(
                            variant: .outline,
                            onPress: controller.toggle,
                            child: Icon(LucideIcons.ellipsis),
                          );
                        },
                      ),
                      FPopoverMenu(
                        menu: [
                          .group(
                            divider: .full,
                            children: [
                              for (final queuedFileEntries
                                  in queuedFiles.value.entries)
                                .item(
                                  title: Text(queuedFileEntries.value.fileName),
                                  subtitle: SizedBox(
                                    width: 300,
                                    child: ValueListenableBuilder<FileProgressData>(
                                      valueListenable: queuedFilesProgress
                                          .value[queuedFileEntries.key]!,
                                      builder: (_, data, _) {
                                        return Padding(
                                          padding: const .symmetric(
                                            vertical: 4,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: .center,
                                            spacing: 8,
                                            children: [
                                              SizedBox(
                                                width: double.infinity,
                                                child: FDeterminateProgress(
                                                  value: data.progress,
                                                ),
                                              ),
                                              Row(
                                                spacing: 8,
                                                mainAxisAlignment:
                                                    .spaceBetween,
                                                children: [
                                                  Text(
                                                    '${TextUtils.formatBytes(data.currentBytes) ?? '--'} / ${TextUtils.formatBytes(data.totalBytes) ?? '--'}',
                                                  ),
                                                  Text(
                                                    '${(data.progress * 100).toStringAsFixed(1)}%',
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                        builder: (_, controller, _) {
                          return FButton.icon(
                            variant: .outline,
                            onPress: controller.toggle,
                            child: RotationTransition(
                              turns: rotation,
                              child: Icon(
                                queuedFiles.value.isEmpty
                                    ? LucideIcons.refreshCwOff
                                    : LucideIcons.refreshCw,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: DragTarget<_SftpDragData>(
                onWillAcceptWithDetails: (details) =>
                    details.data.sessionId != session.id,
                onAcceptWithDetails: (details) async {
                  for (final fileEntry in details.data.files.entries) {
                    debugPrint(
                      'Transferring file from source ${fileEntry.value.path} to destination ${[...?currentDirectory.value, fileEntry.value.fileName].join('/')}',
                    );

                    final index = fileEntry.key;

                    addQueuedFile(index, _FileData(path: fileEntry.value.path));

                    ref
                        .read(sessionProvider.notifier)
                        .transferSftp(
                          source: session,
                          destination: ref
                              .read(sessionProvider.notifier)
                              .getSessionById(details.data.sessionId)!,
                          sourcePath: fileEntry.value.path,
                          localPath: [
                            ...?currentDirectory.value,
                            fileEntry.value.fileName,
                          ].join('/'),
                        )
                        .listen((p) => setQueuedFileProgress(index, p))
                        .onDone(() {
                          setQueuedFileProgress(index, null);
                          // TODO also refresh directory in source SftpSessionPage

                          // refresh directory
                          currentDirectory.value = [...?currentDirectory.value];
                        });
                  }
                },
                builder: (context, data, _) {
                  final files = (currentFiles.value ?? [])
                    ..sort((a, b) {
                      // directories first
                      if (a.attr.isDirectory && !b.attr.isDirectory) {
                        return -1;
                      }
                      if (!a.attr.isDirectory && b.attr.isDirectory) return 1;

                      if (sortColumn.value != null) {
                        final col = sortColumn.value!.$1;
                        final cmp = col.sortableValueBuilder != null
                            ? col.sortableValueBuilder!(a).compareTo(
                                col.sortableValueBuilder!(b),
                              )
                            : col
                                  .valueBuilder(a)
                                  .compareTo(col.valueBuilder(b));
                        if (cmp != 0) return sortColumn.value!.$2 ? cmp : -cmp;
                      }

                      // otherwise just sort by name
                      return a.filename.toLowerCase().compareTo(
                        b.filename.toLowerCase(),
                      );
                    });

                  final fileToIndex = <String, int>{};
                  for (var i = 0; i < files.length; i++) {
                    fileToIndex[getFileIdFromSftpName(files[i])] = i;
                  }

                  getFileFromId(String id) {
                    final index = fileToIndex[id];
                    if (index == null) return null;
                    return files[index];
                  }

                  final visibleCols = _SftpColumn.values
                      .where((c) => visibleColumns.value.contains(c))
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: TableView.builder(
                      key: ValueKey(currentDirectory.value),
                      columns: _SftpColumn.values
                          .where((c) => visibleColumns.value.contains(c))
                          .map((c) => buildTableHeader(c))
                          .toList(),
                      onColumnTap: (index) {
                        if (sortColumn.value == null ||
                            sortColumn.value!.$1 != visibleCols[index]) {
                          sortColumn.value = (visibleCols[index], true);
                        } else {
                          sortColumn.value = (
                            visibleCols[index],
                            !sortColumn.value!.$2,
                          );
                        }
                        selectedFilesIds.value = {};
                      },
                      rowCount: files.length,
                      selectedRows: selectedFilesIds.value
                          .map((id) => fileToIndex[id])
                          .whereType<int>()
                          .toList(growable: false),
                      onRowTap: (index) {
                        final file = files[index];

                        // ignore non-selectable files
                        if (file.filename.isEmpty ||
                            (_ignoredSelectableFilenames.contains(
                                  file.filename,
                                ) &&
                                files.length > 1)) {
                          selectedFilesIds.value = {};
                          return;
                        }

                        final id = getFileIdFromSftpName(file);

                        // shift selects range
                        if (HardwareKeyboard.instance.isShiftPressed &&
                            selectedFilesIds.value.isNotEmpty) {
                          // get first selected index and select all to tapped index
                          final firstIndex =
                              fileToIndex[selectedFilesIds.value.first]!;
                          final range = firstIndex <= index
                              ? [
                                  for (var i = firstIndex; i <= index; i++)
                                    getFileIdFromSftpName(files[i]),
                                ]
                              : [
                                  for (var i = index; i <= firstIndex; i++)
                                    getFileIdFromSftpName(files[i]),
                                ];
                          selectedFilesIds.value = {
                            selectedFilesIds.value.first,
                            ...range,
                          };
                          return;
                        }

                        // ctrl/cmd toggles selection
                        if (HardwareKeyboard.instance.isMetaPressed ||
                            HardwareKeyboard.instance.isControlPressed) {
                          if (selectedFilesIds.value.contains(id)) {
                            selectedFilesIds.value = {
                              ...selectedFilesIds.value..remove(id),
                            };
                          } else {
                            selectedFilesIds.value = {
                              ...selectedFilesIds.value..add(id),
                            };
                          }
                          return;
                        }

                        selectedFilesIds.value = {id};
                      },
                      onRowDoubleTap: (index) {
                        final file = files[index];
                        final id = getFileIdFromSftpName(file);
                        selectedFilesIds.value = {if (file.attr.isFile) id};
                        final _ = switch (file.attr.type) {
                          .directory => onFolderPress(file),
                          .regularFile => onFilePress(file, id),
                          .symbolicLink => onSymlinkPress(file, id),
                          _ => null,
                        };
                      },
                      rowBuilder: (context, index) {
                        final file = files[index];
                        final id = getFileIdFromSftpName(file);

                        final isHidden = isHiddenFile(file);
                        if (isHidden && !showHiddenFiles.value) {
                          return null;
                        }

                        final fileStyle = context.theme.typography.sm.copyWith(
                          color: isHidden
                              ? context.theme.colors.mutedForeground
                              : null,
                        );

                        buildCell(_SftpColumn col) {
                          final text = Text(
                            col.valueBuilder.call(file),
                            overflow: .fade,
                            softWrap: false,
                            style: fileStyle,
                          );

                          final isQueued = queuedFiles.value.containsKey(id);
                          final isModified = modifiedFiles.value.containsKey(
                            id,
                          );

                          if (col.prefixBuilder != null) {
                            return Row(
                              spacing: 8,
                              children: [
                                isQueued
                                    ? SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: FCircularProgress(),
                                      )
                                    : col.prefixBuilder!.call(file),
                                Expanded(child: text),
                                if (isModified && !isQueued) ...[
                                  FButton.icon(
                                    onPress: () => uploadModified(file, id),
                                    child: Icon(LucideIcons.upload),
                                  ),
                                  FButton.icon(
                                    onPress: () => cleanupModified(file, id),
                                    variant: .destructive,
                                    child: Icon(LucideIcons.x),
                                  ),
                                ],
                              ],
                            );
                          }

                          if (col == .size && isModified) {
                            return FutureBuilder(
                              future: File(
                                modifiedFiles.value[id]!.tempPath!,
                              ).length(),
                              builder: (_, snap) => Text.rich(
                                TextSpan(
                                  text: col.valueBuilder.call(file),
                                  children: [
                                    if (snap.hasData)
                                      TextSpan(
                                        text:
                                            ' (${TextUtils.formatBytes(snap.data as int)})',
                                        style: TextStyle(
                                          color: context.theme.colors.primary,
                                        ),
                                      ),
                                  ],
                                ),
                                overflow: .fade,
                                softWrap: false,
                                style: fileStyle,
                              ),
                            );
                          }

                          return text;
                        }

                        buildDragFeedback() {
                          return SizedBox(
                            width: 200,
                            child: Opacity(
                              opacity: 0.7,
                              child: IgnorePointer(
                                ignoring: true,
                                child: FTileGroup(
                                  children: [
                                    for (final id in selectedFilesIds.value)
                                      FTile(
                                        title: Text(
                                          getFileFromId(id)?.filename ??
                                              'Unknown',
                                        ),
                                        prefix: getFileFromId(id) == null
                                            ? null
                                            : _SftpColumn.name.prefixBuilder!
                                                  .call(getFileFromId(id)!),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        return TableViewRow(
                          cells: [
                            for (final col in _SftpColumn.values)
                              if (visibleColumns.value.contains(col))
                                .new(
                                  child: Listener(
                                    onPointerDown: (_) {
                                      if (!selectedFilesIds.value.contains(
                                        id,
                                      )) {
                                        selectedFilesIds.value = {id};
                                      }
                                    },
                                    child: Builder(
                                      builder: (context) {
                                        final selected = <String, _FileData>{};
                                        for (final id
                                            in selectedFilesIds.value) {
                                          final file = getFileFromId(id);
                                          if (file != null) {
                                            final fullPath = [
                                              ...?currentDirectory.value,
                                              file.filename,
                                            ].join('/');

                                            selected[id] = _FileData(
                                              path: fullPath,
                                            );
                                          }
                                        }

                                        return Draggable<_SftpDragData>(
                                          data: _SftpDragData(
                                            sessionId: session.id,
                                            files: selected,
                                          ),
                                          onDragStarted: () {
                                            final isPartOfSelection =
                                                selectedFilesIds.value.contains(
                                                  id,
                                                );
                                            if (!isPartOfSelection) {
                                              selectedFilesIds.value = {id};
                                            }
                                          },
                                          feedback: buildDragFeedback(),
                                          child: buildCell(col),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
