import 'dart:convert';

import 'package:cliq/modules/settings/model/settings_importer/settings_importer.dart';
import 'package:cliq/modules/settings/model/theme_parser/terminal_theme_parser.dart';
import 'package:cliq/shared/ui/responsive_dialog.dart';
import 'package:cliq/shared/utils/constants.dart';
import 'package:cliq/shared/model/router.model.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';

final class Commons {
  const Commons._();

  static XTypeGroup get customTerminalThemeGroup => XTypeGroup(
    label: 'Terminal Theme',
    extensions: TerminalThemeParser.values
        .map((e) => e.fileExtension)
        .toList(growable: false),
  );

  static XTypeGroup get settingsGroup => XTypeGroup(
    label: 'Settings Export',
    extensions: SettingsImporter.values
        .map((e) => e.fileExtension ?? '')
        .toList(growable: false),
  );

  static XTypeGroup get keyGroup =>
      XTypeGroup(label: 'SSH Key', extensions: []);

  static Future<T?> showResponsiveDialog<T>(
    WidgetBuilder builder, {
    BuildContext? context,
  }) {
    return showFSheet(
      context: (Router.rootNavigatorKey.currentContext ?? context)!,
      side: FLayout.rtl,
      mainAxisMaxRatio: 1,
      builder: (context) => ResponsiveDialog(child: builder(context)),
    );
  }

  /// Shows a common confirmation dialog.
  static Future<T?> showConfirmationDialog<T>({
    required List<InlineSpan> Function(
      BuildContext,
      FDialogStyle,
      Animation<double>,
    )
    children,
    VoidCallback? onConfirm,
    BuildContext? context,
    String? title,
    String? confirmButtonText,
  }) {
    return showFDialog(
      context: (Router.rootNavigatorKey.currentContext ?? context)!,
      builder: (context, style, animation) {
        return FDialog(
          style: style,
          animation: animation,
          direction: Axis.horizontal,
          title: title != null ? Text(title) : null,
          body: RichText(
            text: TextSpan(children: children(context, style, animation)),
          ),
          actions: [
            FButton(
              variant: .outline,
              child: const Text('Cancel'),
              onPress: () => Navigator.of(context).pop(false),
            ),
            FButton(
              variant: .destructive,
              child: confirmButtonText != null
                  ? Text(confirmButtonText)
                  : const Text('Confirm'),
              onPress: () {
                onConfirm?.call();
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

  /// Shows a common delete confirmation dialog.
  /// On desktop, if [canInstantDelete] is true, holding shift while triggering the delete action will skip the dialog and immediately call [onDelete].
  static Future<T?> showDeleteDialog<T>({
    required String entity,
    required VoidCallback onDelete,
    BuildContext? context,
    bool canInstantDelete = true,
    bool mayNeedAppRestart = false,
    String? term = 'delete',
  }) {
    if (PlatformUtils.isDesktop &&
        canInstantDelete &&
        HardwareKeyboard.instance.isShiftPressed) {
      onDelete.call();
      return Future.value(null);
    }

    return showConfirmationDialog(
      confirmButtonText: 'Delete',
      title: 'Are you sure?',
      onConfirm: onDelete,
      children: (context, _, _) => TextUtils.renderText(
        context,
        'Are you sure you want to $term <b>$entity</b>? This action cannot be undone.'
        '${PlatformUtils.isDesktop && canInstantDelete ? '\n\n<tip>TIP: Hold <shiftIcon/> to skip this dialog</tip>' : ''}'
        '${mayNeedAppRestart ? '\n\n<tip>NOTE: You may need to restart the app after doing this.</tip>' : ''}',
      ),
    );
  }

  static Future<void> showToast(
    String message, {
    Widget? prefix,
    FToastVariant? variant,
  }) async {
    final context = Router.rootNavigatorKey.currentContext;
    if (context != null) {
      showFToast(
        variant: variant ?? .primary,
        context: context,
        title: Row(
          spacing: 8,
          mainAxisSize: .min,
          children: [
            ?prefix,
            Flexible(child: Text(message)),
          ],
        ),
      );
    }
  }

  static Future<void> copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (context.mounted) {
      showFToast(
        context: context,
        title: Text('Successfully copied to clipboard!'),
      );
    }
  }

  /// Saves the given text to a file. Returns true if the file was saved successfully, false otherwise.
  static Future<bool> saveTextToFile(
    String text,
    String suggestedFileName, {
    List<String>? allowedExtensions,
    String mimeType = 'text/plain',
  }) async {
    final FileSaveLocation? result = await getSaveLocation(
      acceptedTypeGroups: allowedExtensions != null
          ? [XTypeGroup(label: 'Allowed', extensions: allowedExtensions)]
          : [],
      suggestedName: suggestedFileName,
    );

    if (result == null) {
      return false;
    }

    final file = XFile.fromData(
      utf8.encode(text),
      mimeType: mimeType,
      name: suggestedFileName,
    );

    await file.saveTo(result.path);
    return true;
  }

  static Future<void> launchGitHubUrl() => _launchUrl(Constants.githubUrl);
  static Future<void> launchGitHubCreateIssueUrl() =>
      _launchUrl(Constants.githubCreateIssueUrl);

  static Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
