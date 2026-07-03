import 'dart:async';
import 'dart:io';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/session/model/sftp_transfer_params.model.dart';
import 'package:cliq/modules/session/view/generic_session_page.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/constants.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:open_app_file/open_app_file.dart';

import '../../../shared/provider/file_transfer.provider.dart';
import '../../../shared/ui/context_menu.dart';
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
      return Icon(LucideIcons.fileSymlink);
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
  final String path;

  const _FileData({required this.path});

  String get fileName => path.split('/').last;

  String getFileId(String sessionId) => '$sessionId:$path';
}

/// Represents a file that is queued for transfer to/from the SFTP server.
class QueuedFileData extends _FileData {
  final SftpTransferType type;

  const QueuedFileData({required super.path, required this.type});
}

/// Represents a file that has been modified locally and needs to be confirmed before uploading back to the SFTP server.
class _ModifiedFileData extends _FileData {
  final String tempPath;

  const _ModifiedFileData({required super.path, required this.tempPath});
}

class FileProgressData {
  final int currentBytes;
  final int totalBytes;
  final String? error;
  final double? bytesPerSecond;

  const FileProgressData({
    required this.currentBytes,
    required this.totalBytes,
    this.error,
    this.bytesPerSecond,
  });

  int? get estimatedSecondsRemaining {
    if (bytesPerSecond == null || bytesPerSecond! <= 0) return null;
    final remainingBytes = totalBytes - currentBytes;
    return (remainingBytes / bytesPerSecond!).ceil();
  }

  const FileProgressData.completed({this.totalBytes = 1})
    : currentBytes = totalBytes,
      error = null,
      bytesPerSecond = null;

  const FileProgressData.zero()
    : currentBytes = 0,
      totalBytes = 1,
      error = null,
      bytesPerSecond = null;

  const FileProgressData.error(this.error)
    : currentBytes = 0,
      totalBytes = 1,
      bytesPerSecond = null;

  double get progress => totalBytes == 0 ? 0 : currentBytes / totalBytes;

  FileProgressData copyWith({
    int? currentBytes,
    int? totalBytes,
    String? error,
    double? bytesPerSecond,
  }) {
    return FileProgressData(
      currentBytes: currentBytes ?? this.currentBytes,
      totalBytes: totalBytes ?? this.totalBytes,
      error: error ?? this.error,
      bytesPerSecond: bytesPerSecond ?? this.bytesPerSecond,
    );
  }
}

/// Files that should not shown in the file list.
const _ignoredFilenames = {'.'};

/// Files that should not be selectable, editable, or transferable.
const _ignoredSelectableFilenames = {'.', '..'};

/// A special file name (and thus id) used to represent a new folder being created in the file list.
const _createFolderFileName = '@new-folder';

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
        .getSessionById(widget.sessionId);

    if (session == null) return SizedBox.shrink();

    final isLoading = useState(true);
    final largeDownloadWarning = useStore(.sftpLargeDownloadWarning);

    final backStack = useState<List<List<String>>>([]);
    final forwardStack = useState<List<List<String>>>([]);

    final currentDirectory = useState<List<String>?>([]);
    final currentFiles = useState<List<SftpName>?>(null);

    final selectedFilesIds = useState<Set<String>>({});

    final fileTransfers = ref.watch(fileTransferProvider);
    // modified file data that needs to be confirmed by the user before writing
    final modifiedFiles = useState<Map<String, _ModifiedFileData>>({});

    // the id of the file that is currently being renamed, if any
    final renameItemId = useState<String?>(null);
    final renameController = useTextEditingController();

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
    final isCreatingDirectory = useState(false);

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

    getFileIdFromSftpName(SftpName file) {
      return '${session.id}:${[...?currentDirectory.value, file.filename].join('/')}';
    }

    getFileByIndex(int index) {
      if (currentFiles.value == null) return null;
      final files = currentFiles.value!;
      if (index < 0 ||
          index >= files.length + (isCreatingDirectory.value ? 1 : 0)) {
        return null;
      }

      if (isCreatingDirectory.value) {
        if (index == 0) {
          return SftpName(
            filename: _createFolderFileName,
            longname: '', // we don't use the longname anyway
            attr: .new(mode: .value(0x41FF)),
          );
        }
      }

      return files[isCreatingDirectory.value ? index - 1 : index];
    }

    useEffect(() {
      if (renameItemId.value == null) {
        renameController.clear();
      } else {
        final id = renameItemId.value!;
        final file = currentFiles.value
            ?.where((f) => getFileIdFromSftpName(f) == id)
            .firstOrNull;

        if (file != null) {
          renameController.text = file.filename;
          renameController.selection = .new(
            baseOffset: 0,
            extentOffset: file.filename.length,
          );
        }
      }
      return null;
    }, [renameItemId.value]);

    // cleanup modified files that were cleared through the file transfer provider
    useEffect(() {
      final diff = modifiedFiles.value.keys.toSet().difference(
        fileTransfers.queued.keys.toSet(),
      );

      modifiedFiles.value = {
        ...modifiedFiles.value..removeWhere((key, _) => diff.contains(key)),
      };

      return null;
    }, [fileTransfers.queued]);

    // helper for preventing certain actions while loading
    onAction(VoidCallback func) => isLoading.value ? null : func;

    reloadDirectory() {
      currentDirectory.value = [...?currentDirectory.value];
    }

    createDirectory() {
      isCreatingDirectory.value = true;
      renameItemId.value = getFileIdFromSftpName(getFileByIndex(0)!);
    }

    resetRename() {
      renameItemId.value = null;
      isCreatingDirectory.value = false;
    }

    navigateTo(List<String> path) {
      if (currentDirectory.value != null) {
        backStack.value = [...backStack.value, currentDirectory.value!];
      }
      forwardStack.value = [];
      selectedFilesIds.value = {};
      currentDirectory.value = path;
    }

    cleanupModified(SftpName file, String id) async {
      await ref.read(fileTransferProvider.notifier).remove(id);
      modifiedFiles.value = {...modifiedFiles.value..remove(id)};
    }

    openFolder(SftpName file) async {
      if (!file.attr.isDirectory || file.filename.isEmpty) {
        return;
      }
      isLoading.value = true;
      final path =
          await session.sftpClient!.absolute(
              [...?currentDirectory.value, file.filename].join('/'),
            )
            ..trim();

      isLoading.value = false;
      navigateTo(path == '/' ? [''] : path.split('/'));
    }

    openFile(SftpName file, String id) async {
      if (file.attr.isDirectory ||
          file.filename.isEmpty ||
          _ignoredSelectableFilenames.contains(file.filename)) {
        return;
      }

      // check file size & warn user if enabled
      if (largeDownloadWarning.value &&
          file.attr.size! > Constants.largeFileSizeThreshold) {
        final shouldContinue = await Commons.showConfirmationDialog(
          title: 'Large file',
          children: (context, _, _) => TextUtils.renderText(
            context,
            'The file <b>${file.filename}</b> is larger than <b>${TextUtils.formatBytes(Constants.largeFileSizeThreshold, decimals: 0)} (${TextUtils.formatBytes(file.attr.size)})</b> and may take a long time to download. You can edit the file once it has been downloaded.\nDo you want to continue?\n\n<tip>TIP: You can disable this warning in <b>Settings > SSH & SFTP > Large Downloads Warning</b>.</tip>',
          ),
          confirmButtonText: 'Download & Edit',
        );

        if (shouldContinue != true) {
          return;
        }
      }

      final fullPath = [...?currentDirectory.value, file.filename].join('/');
      final fullName =
          '${tempDir.path}${Platform.pathSeparator}${file.filename}';
      File tempFile = File(fullName);

      ref
          .read(fileTransferProvider.notifier)
          .add(
            id,
            .new(path: tempFile.path, type: .remoteToLocal),
            tempFile: tempFile,
          );

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
          }
        }

        file.parent.watch().listen((event) async {
          if (event.path != tempFile.path) return;
          if (event.type == FileSystemEvent.create ||
              event.type == FileSystemEvent.modify) {
            modifiedFiles.value = {
              ...modifiedFiles.value,
              id: .new(path: fullPath, tempPath: tempFile.path),
            };
          }
        });
      }

      final fileTransferNotifier = ref.read(fileTransferProvider.notifier);

      fileTransferNotifier
          .transferSftp(
            id,
            source: session,
            sourcePath: fullPath,
            localPath: tempFile.path,
          )
          .listen((p) => fileTransferNotifier.setProgress(id, p))
          .onDone(() async => await attemptOpenAndWatch(tempFile));
    }

    openSymlink(SftpName file, String id) async {
      if (!file.attr.isSymbolicLink || file.filename.isEmpty) return;
      isLoading.value = true;

      final symlinkPath = [...?currentDirectory.value, file.filename].join('/');
      final targetAttr = await session.sftpClient!.stat(symlinkPath);

      if (targetAttr.isDirectory) {
        final absolutePath = await session.sftpClient!.absolute(symlinkPath);
        navigateTo(absolutePath.split('/'));
      } else {
        await openFile(file, id);
      }

      isLoading.value = false;
    }

    /// Renames a file/directory or creates a new directory if [isCreatingDirectory] is true.
    renameItemOrCreateDirectory(
      SftpName file,
      String id,
      String newFileName,
    ) async {
      if (_ignoredSelectableFilenames.contains(file.filename)) {
        return;
      }

      newFileName = newFileName.trim();
      if (newFileName.isEmpty || newFileName == file.filename) {
        resetRename();
        return;
      }

      final oldPath = [...?currentDirectory.value, file.filename].join('/');
      final newPath = [...?currentDirectory.value, newFileName].join('/');

      try {
        if (isCreatingDirectory.value) {
          await session.sftpClient!.mkdir(newPath);
        } else {
          await session.sftpClient!.rename(oldPath, newPath);
        }
        resetRename();
        reloadDirectory();
      } on SftpStatusError catch (e) {
        if (!context.mounted) return;

        String message = e.message;
        if (e.code == 4) {
          message = 'A file with that name already exists.';
        }

        Commons.showToast(
          'Failed to rename: $message',
          prefix: Icon(
            LucideIcons.pencilOff,
            size: 20,
            color: context.theme.colors.destructive,
          ),
          variant: .destructive,
        );

        resetRename();
      }
    }

    deleteItem(SftpName file, String id) async {
      if (_ignoredSelectableFilenames.contains(file.filename)) {
        return;
      }

      delete() async {
        final fullPath = [...?currentDirectory.value, file.filename].join('/');
        await (file.attr.isDirectory
            ? session.sftpClient!.rmdir(fullPath)
            : session.sftpClient!.remove(fullPath));

        cleanupModified(file, id);

        reloadDirectory();
      }

      Commons.showDeleteDialog(entity: file.filename, onDelete: delete);
    }

    uploadModified(SftpName file, String id) {
      if (_ignoredSelectableFilenames.contains(file.filename)) {
        return;
      }

      final modifiedFile = modifiedFiles.value[id];
      if (modifiedFile == null) return;
      final fileTransferNotifier = ref.read(fileTransferProvider.notifier);

      fileTransferNotifier.add(
        id,
        .new(path: modifiedFile.tempPath, type: .localToRemote),
      );

      fileTransferNotifier
          .transferSftp(
            id,
            localPath: modifiedFiles.value[id]!.tempPath,
            destination: session,
            destinationPath: [
              ...?currentDirectory.value,
              file.filename,
            ].join('/'),
          )
          .listen((p) => fileTransferNotifier.setProgress(id, p))
          .onDone(() async {
            cleanupModified(file, id);
            reloadDirectory();
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
                      FTooltip(
                        tipBuilder: (_, _) => Text('Navigate back'),
                        child: FButton.icon(
                          variant: .outline,
                          onPress: backStack.value.isEmpty
                              ? null
                              : onAction(() {
                                  forwardStack.value = [
                                    currentDirectory.value!,
                                    ...forwardStack.value,
                                  ];
                                  currentDirectory.value = backStack.value.last;
                                  backStack.value = backStack.value.sublist(
                                    0,
                                    backStack.value.length - 1,
                                  );
                                }),
                          child: Icon(LucideIcons.arrowLeft),
                        ),
                      ),
                      FTooltip(
                        tipBuilder: (_, _) => Text('Navigate forward'),
                        child: FButton.icon(
                          variant: .outline,
                          onPress: forwardStack.value.isEmpty
                              ? null
                              : onAction(() {
                                  backStack.value = [
                                    ...backStack.value,
                                    currentDirectory.value!,
                                  ];
                                  currentDirectory.value =
                                      forwardStack.value.first;
                                  forwardStack.value = forwardStack.value
                                      .sublist(1);
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
                                  navigateTo(
                                    currentDirectory.value!.sublist(
                                      0,
                                      index + 1,
                                    ),
                                  );
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
                                onPress: onAction(reloadDirectory),
                              ),
                              .item(
                                title: Text('New folder'),
                                prefix: Icon(LucideIcons.folderPlus),
                                onPress: onAction(createDirectory),
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
                    final id = fileEntry.key;

                    final fileTransferNotifier = ref.read(
                      fileTransferProvider.notifier,
                    );

                    final destinationPath = [
                      ...?currentDirectory.value,
                      fileEntry.value.fileName,
                    ].join('/');

                    transfer() {
                      fileTransferNotifier.add(
                        id,
                        .new(path: fileEntry.value.path, type: .remoteToRemote),
                      );

                      final sourceSession = ref
                          .read(sessionProvider.notifier)
                          .getSessionById(details.data.sessionId)!;

                      fileTransferNotifier
                          .transferSftp(
                            id,
                            source: sourceSession,
                            sourcePath: fileEntry.value.path,
                            destination: session,
                            destinationPath: destinationPath,
                          )
                          .listen(
                            (p) => fileTransferNotifier.setProgress(id, p),
                          )
                          .onDone(reloadDirectory);
                    }

                    // check if file exists
                    try {
                      await session.sftpClient!.stat(destinationPath);
                      Commons.showDeleteDialog(
                        term: 'overwrite',
                        entity: fileEntry.value.fileName,
                        onDelete: transfer,
                        canInstantDelete: false,
                      );
                    } on SftpStatusError catch (_) {
                      transfer();
                    }
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
                    fileToIndex[getFileIdFromSftpName(getFileByIndex(i)!)] = i;
                  }

                  getFileFromId(String id) {
                    final index = fileToIndex[id];
                    if (index == null) return null;
                    return getFileByIndex(index)!;
                  }

                  final visibleCols = _SftpColumn.values
                      .where((c) => visibleColumns.value.contains(c))
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: TableView.builder(
                      key: ValueKey(currentDirectory.value),
                      actions: [
                        .new(
                          label: 'Refresh',
                          icon: LucideIcons.refreshCw,
                          onPress: reloadDirectory,
                        ),
                        .new(
                          label: 'New folder',
                          icon: LucideIcons.folderPlus,
                          onPress: createDirectory,
                        ),
                      ],
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
                      rowCount:
                          files.length + (isCreatingDirectory.value ? 1 : 0),
                      selectedRows: selectedFilesIds.value
                          .map((id) => fileToIndex[id])
                          .whereType<int>()
                          .toList(growable: false),
                      onRowTap: (index) {
                        final file = getFileByIndex(index)!;

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
                                    getFileIdFromSftpName(getFileByIndex(i)!),
                                ]
                              : [
                                  for (var i = index; i <= firstIndex; i++)
                                    getFileIdFromSftpName(getFileByIndex(i)!),
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
                        final file = getFileByIndex(index)!;
                        final id = getFileIdFromSftpName(file);
                        selectedFilesIds.value = {if (file.attr.isFile) id};
                        final _ = switch (file.attr.type) {
                          .directory => openFolder(file),
                          .regularFile => openFile(file, id),
                          .symbolicLink => openSymlink(file, id),
                          _ => null,
                        };
                      },
                      rowBuilder: (context, index) {
                        final file = getFileByIndex(index)!;
                        final id = getFileIdFromSftpName(file);

                        final isHidden = isHiddenFile(file);
                        if (isHidden && !showHiddenFiles.value) {
                          return null;
                        }

                        final fileStyle = context.theme.typography.body.sm
                            .copyWith(
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

                          final isQueued = ref
                              .read(fileTransferProvider)
                              .isPending(id);
                          final isModified = modifiedFiles.value.containsKey(
                            id,
                          );
                          final isRename =
                              renameItemId.value == id && col == .name;

                          if (isRename) {
                            return CallbackShortcuts(
                              bindings: {
                                const SingleActivator(.escape): resetRename,
                              },
                              child: FTextField(
                                control: .managed(controller: renameController),
                                autofocus: true,
                                onSubmit: (value) =>
                                    renameItemOrCreateDirectory(
                                      file,
                                      id,
                                      value,
                                    ),
                                onTapOutside: (_) =>
                                    renameItemOrCreateDirectory(
                                      file,
                                      id,
                                      renameController.text,
                                    ),
                              ),
                            );
                          } else if (col.prefixBuilder != null) {
                            return Row(
                              spacing: 4,
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
                                    variant: .primary,
                                    child: Icon(LucideIcons.upload),
                                  ),
                                  FButton.icon(
                                    onPress: () => cleanupModified(file, id),
                                    variant: .destructive,
                                    child: Icon(LucideIcons.trash),
                                  ),
                                ],
                              ],
                            );
                          }

                          if (col == .size && isModified) {
                            return FutureBuilder(
                              future: File(
                                modifiedFiles.value[id]!.tempPath,
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
                                    onPointerDown: (event) {
                                      if (event.buttons !=
                                              kPrimaryMouseButton &&
                                          !selectedFilesIds.value.contains(
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
                      rowWrapper: (context, child, index) {
                        final file = getFileByIndex(index)!;
                        final id = getFileIdFromSftpName(file);

                        return CustomContextMenu(
                          actions: [
                            if (file.attr.isFile)
                              .new(
                                label: 'Open',
                                icon: LucideIcons.filePen,
                                onPress: () => openFile(file, id),
                              ),
                            if (file.attr.isDirectory)
                              .new(
                                label: 'Open',
                                icon: LucideIcons.folderOpen,
                                onPress: () => openFolder(file),
                              ),
                            if (!_ignoredSelectableFilenames.contains(
                              file.filename,
                            )) ...[
                              .new(
                                label: 'Rename',
                                icon: LucideIcons.pencilLine,
                                onPress: () => renameItemId.value = id,
                              ),
                              .new(
                                label: 'Delete',
                                icon: LucideIcons.trash,
                                variant: .destructive,
                                onPress: () => deleteItem(file, id),
                              ),
                            ],
                          ],
                          builder: (_) => child,
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
