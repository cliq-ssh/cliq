import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/provider/file_transfer.provider.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/utils/constants.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/model/page_path.model.dart';

class SshSftpSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'ssh-sftp',
  );

  const SshSftpSettingsPage({super.key});

  @override
  String get title => 'SSH & SFTP';

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final sshScrollbackSize = useStore(.sshScrollbackSize);
    final showHiddenFiles = useStore(.sftpShowHiddenFiles);
    final largeDownloadsWarning = useStore(.sftpLargeDownloadWarning);
    final directoryNotEmptyWarning = useStore(.sftpDirectoryNotEmptyWarning);

    final refreshTrigger = useState(0);
    final tempDirSizeFuture = useMemoized(
      () => ref.read(fileTransferProvider.notifier).readTempDirectorySize(),
      [refreshTrigger.value],
    );

    final sshScrollbackSizeController = useTextEditingController(
      text: sshScrollbackSize.value.toString(),
    );

    onScrollbackSubmit(String value) {
      int amount = int.tryParse(value) ?? sshScrollbackSize.value;

      if (amount < TerminalBuffer.minMaxScrollbackLines) {
        amount = TerminalBuffer.minMaxScrollbackLines;
      }
      if (amount > TerminalBuffer.maxMaxScrollbackLines) {
        amount = TerminalBuffer.maxMaxScrollbackLines;
      }
      StoreKey.sshScrollbackSize.write(amount);
      sshScrollbackSizeController.text = amount.toString();
    }

    return SingleChildScrollView(
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                child: Column(
                  mainAxisAlignment: .center,
                  spacing: 16,
                  children: [
                    FTileGroup(
                      label: Text('SSH'),
                      children: [
                        FTile(
                          title: Text('Scrollback'),
                          subtitle: Text(
                            'The maximum number of lines to keep in the terminal',
                          ),
                          prefix: Icon(LucideIcons.history),
                          suffix: SizedBox(
                            width: 150,
                            child: FTextField(
                              control: FTextFieldControl.managed(
                                controller: sshScrollbackSizeController,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onSubmit: onScrollbackSubmit,
                            ),
                          ),
                        ),
                      ],
                    ),
                    FTileGroup(
                      label: Text('SFTP'),
                      children: [
                        FTile(
                          title: Text('Show Hidden Files'),
                          subtitle: Text(
                            'Show hidden files in SFTP file listings',
                          ),
                          prefix: Icon(LucideIcons.fileSearchCorner),
                          suffix: FSwitch(
                            value: showHiddenFiles.value,
                            onChange: (value) =>
                                StoreKey.sftpShowHiddenFiles.write(value),
                          ),
                        ),
                        FTile(
                          title: Text('Large Downloads Warning'),
                          subtitle: Text(
                            'Warn when downloading large files (${TextUtils.formatBytes(Constants.largeFileSizeThreshold, decimals: 0)}) over SFTP',
                          ),
                          prefix: Icon(LucideIcons.fileExclamationPoint),
                          suffix: FSwitch(
                            value: largeDownloadsWarning.value,
                            onChange: (value) =>
                                StoreKey.sftpLargeDownloadWarning.write(value),
                          ),
                        ),
                        FTile(
                          title: Text('Directory Not Empty Warning'),
                          subtitle: Text(
                            'Warn when attempting to delete a non-empty directory over SFTP',
                          ),
                          prefix: Icon(LucideIcons.folders),
                          suffix: FSwitch(
                            value: directoryNotEmptyWarning.value,
                            onChange: (value) => StoreKey
                                .sftpDirectoryNotEmptyWarning
                                .write(value),
                          ),
                        ),
                        FTile(
                          title: Row(
                            children: [
                              Row(
                                children: [
                                  Text('Clear temporary files'),
                                  FutureBuilder(
                                    future: tempDirSizeFuture,
                                    builder: (context, snap) {
                                      if (snap.hasData) {
                                        final formatted = TextUtils.formatBytes(
                                          snap.data!,
                                        );
                                        if (formatted != null) {
                                          return Text(' ($formatted)');
                                        }
                                      }
                                      return SizedBox.shrink();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          subtitle: Text(
                            'Clear temporary files used for local editing of remote files',
                          ),
                          prefix: Icon(LucideIcons.brushCleaning),
                          variant: .destructive,
                          onPress: () async {
                            await ref
                                .read(fileTransferProvider.notifier)
                                .clearTempDirectory();
                            refreshTrigger.value++;
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
