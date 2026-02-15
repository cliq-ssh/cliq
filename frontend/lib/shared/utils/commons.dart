import 'package:cliq/modules/settings/model/terminal_theme_parser/terminal_theme_parser.dart';
import 'package:cliq/shared/ui/responsive_dialog.dart';
import 'package:cliq/shared/utils/constants.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
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
    BuildContext context,
    WidgetBuilder builder,
  ) {
    return showFSheet(
      context: context,
      side: FLayout.rtl,
      mainAxisMaxRatio: 1,
      builder: (context) => ResponsiveDialog(child: builder(context)),
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
