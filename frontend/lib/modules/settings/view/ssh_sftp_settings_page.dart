import 'package:cliq/modules/settings/view/abstract_settings_page.dart';
import 'package:cliq/modules/settings/view/settings_page.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/provider/file_transfer.provider.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/ui/custom_toggle_tile.dart';
import 'package:cliq/shared/utils/constants.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridContainer, CliqGridRow, CliqGridColumn;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart' hide Router;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/model/page_path.model.dart';

//TODO: add proper error handling
class SshSftpSettingsPage extends AbstractSettingsPage {
  static const PagePathBuilder pagePath = PagePathBuilder.child(
    parent: SettingsPage.pagePath,
    path: 'ssh-sftp',
  );

  const SshSftpSettingsPage({super.key});

  @override
  String get title => 'ssh_sftp'.tr();

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final sshScrollbackSize = useStore(.sshScrollbackSize);
    final cursorBlinkInterval = useStore(.terminalCursorBlinkInterval);
    final cursorBlinkTimeout = useStore(.terminalCursorBlinkTimeout);

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

    final cursorBlinkIntervalController = useTextEditingController(
      text: cursorBlinkInterval.value.toString(),
    );

    final cursorBlinkTimeoutController = useTextEditingController(
      text: cursorBlinkTimeout.value.toString(),
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

    onCursorBlinkIntervalSubmit(String value) {
      int amount = int.tryParse(value) ?? cursorBlinkInterval.value;
      if (amount < CursorState.minCursorBlinkInterval) {
        amount = CursorState.minCursorBlinkInterval;
      }
      if (amount > CursorState.maxCursorBlinkInterval) {
        amount = CursorState.maxCursorBlinkInterval;
      }
      StoreKey.terminalCursorBlinkInterval.write(amount);
      cursorBlinkIntervalController.text = amount.toString();
    }

    onCursorBlinkTimeoutSubmit(String value) {
      int amount = int.tryParse(value) ?? cursorBlinkTimeout.value;
      if (amount < CursorState.minCursorBlinkTimeout) {
        amount = CursorState.minCursorBlinkTimeout;
      }
      if (amount > CursorState.maxCursorBlinkTimeout) {
        amount = CursorState.maxCursorBlinkTimeout;
      }
      StoreKey.terminalCursorBlinkTimeout.write(amount);
      cursorBlinkTimeoutController.text = amount.toString();
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
                      label: Text('ssh'.tr()),
                      children: [
                        FTile(
                          title: Text('ssh_sftp_scrollback'.tr()),
                          subtitle: Text(
                            'ssh_sftp_scrollback_subtitle'.tr(),
                            overflow: .visible,
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
                        FTile(
                          title: Text(
                            'ssh_sftp_terminal_cursor_blink_interval'.tr(),
                          ),
                          subtitle: Text(
                            'ssh_sftp_terminal_cursor_blink_interval_subtitle'
                                .tr(),
                            overflow: .visible,
                          ),
                          prefix: Icon(LucideIcons.timer),
                          suffix: SizedBox(
                            width: 150,
                            child: FTextField(
                              control: FTextFieldControl.managed(
                                controller: cursorBlinkIntervalController,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onSubmit: onCursorBlinkIntervalSubmit,
                            ),
                          ),
                        ),
                        FTile(
                          title: Text(
                            'ssh_sftp_terminal_cursor_blink_timeout'.tr(),
                          ),
                          subtitle: Text(
                            'ssh_sftp_terminal_cursor_blink_timeout_subtitle'
                                .tr(),
                            overflow: .visible,
                          ),
                          prefix: Icon(LucideIcons.timerOff),
                          suffix: SizedBox(
                            width: 150,
                            child: FTextField(
                              control: FTextFieldControl.managed(
                                controller: cursorBlinkTimeoutController,
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onSubmit: onCursorBlinkTimeoutSubmit,
                            ),
                          ),
                        ),
                      ],
                    ),
                    FTileGroup(
                      label: Text('sftp'.tr()),
                      children: [
                        CustomToggleTile(
                          title: 'ssh_sftp_show_hidden_files',
                          subtitle: 'ssh_sftp_show_hidden_files_subtitle',
                          prefix: Icon(LucideIcons.fileSearchCorner),
                          storeKey: .sftpShowHiddenFiles,
                          value: showHiddenFiles.value,
                        ),
                        CustomToggleTile(
                          title: 'ssh_sftp_large_download_warning',
                          subtitle: 'ssh_sftp_large_download_warning_subtitle',
                          subtitleArgs: [
                            TextUtils.formatBytes(
                              Constants.largeFileSizeThreshold,
                              decimals: 0,
                            )!,
                          ],
                          prefix: Icon(LucideIcons.fileExclamationPoint),
                          storeKey: .sftpLargeDownloadWarning,
                          value: largeDownloadsWarning.value,
                        ),
                        CustomToggleTile(
                          title: 'ssh_sftp_directory_not_empty_warning',
                          subtitle:
                              'ssh_sftp_directory_not_empty_warning_subtitle',
                          prefix: Icon(LucideIcons.folders),
                          storeKey: .sftpDirectoryNotEmptyWarning,
                          value: directoryNotEmptyWarning.value,
                        ),
                        FTile(
                          title: Row(
                            children: [
                              Row(
                                children: [
                                  Text('ssh_sftp_clear_temporary_files'.tr()),
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
                            'ssh_sftp_clear_temporary_files_subtitle'.tr(),
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
