import 'package:cliq/shared/model/localized_exception.dart';
import 'package:cliq_ui/cliq_ui.dart' show CliqFontFamily;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:simple_icons/simple_icons.dart';

import '../utils/commons.dart';

class ErrorView extends ConsumerWidget {
  final Object error;
  final StackTrace? stackTrace;

  const ErrorView({super.key, required this.error, this.stackTrace});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveError = error is LocalizedException
        ? (error as LocalizedException).tr(context)
        : error.toString();

    buildErrorDetailsCard(String content) {
      return Row(
        children: [
          Expanded(
            child: FCard(
              style: .delta(
                decoration: .boxDelta(
                  color: context.theme.colors.destructive.withValues(
                    alpha: 0.1,
                  ),
                  border: Border.all(
                    color: context.theme.colors.destructive.withValues(
                      alpha: 0.2,
                    ),
                  ),
                ),
              ),
              child: Text(
                content,
                style: context.theme.typography.body.xs.copyWith(
                  fontFamily: CliqFontFamily.secondary.fontFamily,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return FScaffold(
      childPad: false,
      child: SingleChildScrollView(
        padding: const .symmetric(horizontal: 32, vertical: 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FButton.icon(
                  variant: .outline,
                  onPress: () => context.pop(),
                  child: const Icon(LucideIcons.x),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              spacing: 16,
              children: [
                buildErrorDetailsCard(effectiveError),
                if (stackTrace != null && stackTrace != StackTrace.empty)
                  FAccordion(
                    children: [
                      FAccordionItem(
                        title: Text('error_stacktrace'.tr()),
                        child: buildErrorDetailsCard(stackTrace.toString()),
                      ),
                    ],
                  ),
                FTileGroup(
                  children: [
                    FTile(
                      prefix: Icon(LucideIcons.bug),
                      title: Text('error_copy_error_details'.tr()),
                      onPress: () {
                        final details =
                            'Error: $error\n\nStacktrace:\n${stackTrace ?? "No stack trace available."}';
                        Commons.copyToClipboard(context, details);
                      },
                    ),
                    FTile(
                      prefix: Icon(SimpleIcons.github),
                      suffix: Icon(LucideIcons.externalLink),
                      title: Text('error_report_issue_on_github'.tr()),
                      onPress: () => Commons.launchGitHubCreateIssueUrl(),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
