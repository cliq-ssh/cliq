import 'package:cliq/shared/ui/responsive_dialog.dart';
import 'package:cliq/shared/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:url_launcher/url_launcher.dart';

final class Commons {
  const Commons._();

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

  static Future<void> launchGitHubUrl() => _launchUrl(Constants.githubUrl);

  static Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }
}
