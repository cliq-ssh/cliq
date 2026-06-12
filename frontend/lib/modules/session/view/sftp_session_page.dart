import 'dart:async';

import 'package:cliq/modules/connections/model/connection_full.model.dart';
import 'package:cliq/modules/connections/provider/connection.provider.dart';
import 'package:cliq/modules/session/view/generic_session_page.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/ui/navigation_shell.dart';
import '../provider/session.provider.dart';

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

    final currentDirectory = useState<List<String>?>([]);
    final currentFiles = useState<List<SftpName>?>(null);

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
        final path = currentDirectory.value!.join('/');

        currentFiles.value = await session.sftpClient!.listdir(
          path.isEmpty ? '/' : path,
        );
        isLoading.value = false;
      }

      fetch();
      return null;
    }, [currentDirectory.value]);

    getFileIcon(SftpName file) {
      if (file.attr.isDirectory) {
        return LucideIcons.folder;
      }
      if (file.attr.isSymbolicLink) {
        return LucideIcons.fileInput;
      }
      return LucideIcons.file;
    }

    onFilePress(SftpName file) async {
      if (isLoading.value || !file.attr.isDirectory || file.filename.isEmpty) {
        return;
      }
      isLoading.value = true;
      final path =
          await session.sftpClient!.absolute(
              [...?currentDirectory.value, file.filename].join('/'),
            )
            ..trim();

      currentDirectory.value = path == '/' ? [''] : path.split('/');
      isLoading.value = false;
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
              padding: const .only(top: 8, left: 8),
              child: FBreadcrumb(
                children: [
                  for (final part in currentDirectory.value!)
                    FBreadcrumbItem(
                      child: Text(part.isEmpty ? '/' : part),
                      onPress: () {
                        final index = currentDirectory.value!.indexOf(part);
                        currentDirectory.value = currentDirectory.value!
                            .sublist(0, index + 1);
                      },
                    ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                if (isLoading.value) {
                  return Expanded(child: Center(child: FCircularProgress()));
                }

                final files = (currentFiles.value ?? [])
                  ..sort((a, b) {
                    // directories first
                    if (a.attr.isDirectory && !b.attr.isDirectory) {
                      return -1;
                    }
                    if (!a.attr.isDirectory && b.attr.isDirectory) return 1;
                    // then by name
                    return a.filename.toLowerCase().compareTo(
                      b.filename.toLowerCase(),
                    );
                  });

                return Expanded(
                  child: ListView.separated(
                    padding: const .symmetric(horizontal: 8),
                    itemCount: files.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      return FTile(
                        title: Text(files[index].filename),
                        subtitle: Text(files[index].longname),
                        prefix: Icon(getFileIcon(files[index])),
                        suffix: files[index].attr.isDirectory
                            ? const Icon(LucideIcons.chevronRight)
                            : null,
                        onPress: () => onFilePress(files[index]),
                      );
                    },
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
