import 'package:cliq/shared/utils/constants.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';

final class Commons {
  const Commons._();

  static Future<T?> showResponsiveDialog<T>(
    BuildContext context,
    Breakpoint currentBreakpoint,
    Widget Function(BuildContext) builder,
  ) {
    if (currentBreakpoint.index >= Breakpoint.md.index) {
      return showFSheet(context: context, side: FLayout.rtl, builder: builder);
    }

    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: builder, fullscreenDialog: true));
  }

  static Future<void> launchGitHubUrl() => _launchUrl(Constants.githubUrl);

  static Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
