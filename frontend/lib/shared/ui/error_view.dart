import 'package:cliq/shared/data/database.dart';
import 'package:cliq_ui/cliq_ui.dart' show CliqFontFamily;
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
    return FScaffold(
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
                FCard(
                  style: .delta(
                    decoration: .boxDelta(
                      color: context.theme.colors.destructive.withValues(alpha: 0.1),
                      border: Border.all(color: context.theme.colors.destructive.withValues(alpha: 0.2))
                    )
                  ),
                    child: Text(
                        error.toString(),
                        style: context.theme.typography.xs.copyWith(fontFamily: CliqFontFamily.secondary.fontFamily),
                    )),
                FTileGroup(
                  children: [
                    FTile(
                      prefix: Icon(LucideIcons.bug),
                      title: Text('Copy Error Details'),
                      onPress: () {
                        final details = 'Error: $error\n\nStack Trace:\n${stackTrace ?? "No stack trace available."}';
                        Commons.copyToClipboard(context, details);
                      },
                    ),
                    FTile(
                      prefix: Icon(SimpleIcons.github),
                      suffix: Icon(LucideIcons.externalLink),
                      title: Text('Report Issue on GitHub'),
                      onPress: () => Commons.launchGitHubCreateIssueUrl(),
                    ),
                  ],
                ),
                FTileGroup(
                  children: [
                    // TODO: option for opening the db directory in file explorer
                    FTile(
                      variant: .destructive,
                      prefix: Icon(LucideIcons.databaseBackup),
                      title: Text('Reset Database Tables'),
                      onPress: () => Commons.showDeleteDialog(
                        entity: 'ALL DATABASE TABLES',
                        onDelete: () => CliqDatabase.instance.deleteAllTables(),
                        canInstantDelete: false,
                        mayNeedAppRestart: true
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
