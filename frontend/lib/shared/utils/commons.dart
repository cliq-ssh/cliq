import 'package:cliq/modules/settings/model/terminal_theme_parser/terminal_theme_parser.dart';
import 'package:cliq/shared/ui/responsive_dialog.dart';
import 'package:cliq/shared/ui/shortcut_info.dart';
import 'package:cliq/shared/utils/constants.dart';
import 'package:cliq/shared/model/router.model.dart';
import 'package:cliq/shared/utils/platform_utils.dart';
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

  /// Shows a common delete confirmation dialog.
  /// On desktop, if [canInstantDelete] is true, holding shift while triggering the delete action will skip the dialog and immediately call [onDelete].
  static Future<T?> showDeleteDialog<T>({
    required String entity,
    required VoidCallback onDelete,
    BuildContext? context,
    bool canInstantDelete = true,
  }) {
    if (PlatformUtils.isDesktop &&
        canInstantDelete &&
        HardwareKeyboard.instance.isShiftPressed) {
      onDelete.call();
      return Future.value(null);
    }

    return showFDialog(
      context: (Router.rootNavigatorKey.currentContext ?? context)!,
      builder: (context, style, animation) {
        final subtitleStyle = context.theme.typography.sm.copyWith(
          color: context.theme.colors.mutedForeground,
        );
        return FDialog(
          style: style,
          animation: animation,
          direction: Axis.horizontal,
          title: const Text('Are you sure?'),
          body: RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: entity,
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: .bold,
                  ),
                ),
                TextSpan(text: '? This action cannot be undone.'),
                if (PlatformUtils.isDesktop && canInstantDelete) ...[
                  TextSpan(text: '\n\nTIP: Hold ', style: subtitleStyle),
                  WidgetSpan(
                    child: ShortcutInfo(shortcut: ShortcutActionInfo(.shift)),
                  ),
                  TextSpan(text: ' to skip this dialog', style: subtitleStyle),
                ],
              ],
            ),
          ),
          actions: [
            FButton(
              variant: .outline,
              child: const Text('Cancel'),
              onPress: () => Navigator.of(context).pop(),
            ),
            FButton(
              variant: .destructive,
              child: const Text('Delete'),
              onPress: () {
                onDelete.call();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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

  static Future<void> launchGitHubUrl() => _launchUrl(Constants.githubUrl);

  static Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
