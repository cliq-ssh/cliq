import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/session/view/generic_session_page.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

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

const _ignoredFilenames = {'.'};

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

    final visibleColumns = useState<Set<_SftpColumn>>({
      .name,
      .modified,
      .size,
      .kind,
    });
    final sortColumn = useState<(_SftpColumn, bool)?>(null);
    final showHiddenFiles = useState(false);

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

    // helper for preventing certain actions while loading
    onAction(VoidCallback func) => isLoading.value ? null : func;

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

      currentDirectory.value = path == '/' ? [''] : path.split('/');
      navigateBackBuffer.value = null;
      isLoading.value = false;
    }

    void onFilePress(SftpName file) {
      // TODO: copy file to temp directory, open with default app and watch for changes to sync back
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

    isHiddenFile(SftpName file) {
      if (file.filename.isEmpty || file.filename == '..') return false;
      return file.filename.startsWith('.');
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
                                onPress: () => showHiddenFiles.value =
                                    !showHiddenFiles.value,
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
            Builder(
              builder: (context) {
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
                          : col.valueBuilder(a).compareTo(col.valueBuilder(b));
                      if (cmp != 0) return sortColumn.value!.$2 ? cmp : -cmp;
                    }

                    // otherwise just sort by name
                    return a.filename.toLowerCase().compareTo(
                      b.filename.toLowerCase(),
                    );
                  });

                final visibleCols = _SftpColumn.values
                    .where((c) => visibleColumns.value.contains(c))
                    .toList();

                return Expanded(
                  child: Padding(
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
                      },
                      rowCount: files.length,
                      onRowTap: (index) {
                        final file = files[index];
                        return file.attr.isDirectory
                            ? onFolderPress(file)
                            : onFilePress(file);
                      },
                      rowBuilder: (context, index) {
                        final file = files[index];

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

                          if (col.prefixBuilder != null) {
                            return Row(
                              spacing: 8,
                              children: [
                                col.prefixBuilder!.call(file),
                                Flexible(child: text),
                              ],
                            );
                          }

                          return text;
                        }

                        return TableViewRow(
                          cells: [
                            for (final col in _SftpColumn.values)
                              if (visibleColumns.value.contains(col))
                                .new(child: buildCell(col)),
                          ],
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
