import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/modules/settings/model/known_host_error.model.dart';
import 'package:cliq/shared/provider/tab.provider.dart';
import 'package:cliq/shared/ui/cliq_tooltip.dart';
import 'package:cliq/shared/ui/error_card.dart';
import 'package:cliq/shared/ui/title_card.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:cliq_grid/cliq_grid.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:material_ui/material_ui.dart' hide LicensePage, Tab;

class const GenericSessionPage({
  super.key,
  required final WidgetBuilder builder,
  required final String tabId,
  required final SshSession session,
  final void Function({bool skipHostKeyVerification})? onRetry,
}) extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.theme.typography;

    close() {
      ref.read(tabProvider.notifier).close(tabId);
    }

    buildConnecting() {
      return [
        const FCircularProgress(),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: TextUtils.renderText(
              context,
              'hosts_connecting_to'.tr(args: [session.connection.address]),
            ),
          ),
          style: typography.body.xl,
        ),
      ];
    }

    buildKnownHostError(KnownHostError error) {
      return [
        const Icon(LucideIcons.fingerprintPattern, size: 48),
        const SizedBox(height: 16),
        Text.rich(
          textAlign: .center,
          TextSpan(
            children: TextUtils.renderText(
              context,
              (error.knownHost != null
                      ? 'hosts_update_fingerprint_title'
                      : 'hosts_accept_fingerprint_title')
                  .tr(args: [error.host]),
            ),
          ),
          style: typography.body.xl,
        ),
        if (error.knownHost != null)
          Text(
            'hosts_update_fingerprint_subtitle'.tr(),
            style: typography.body.md.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
            textAlign: .center,
          ),
        const SizedBox(height: 16),
        TitleCard(
          subtitle: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text('${error.algorithm} (SHA256)'),
              CliqTooltip(
                text: Text('click_to_copy'.tr()),
                child: FButton.icon(
                  onPress: () =>
                      Commons.copyToClipboard(context, error.fingerprintString),
                  child: const Icon(LucideIcons.copy, size: 14),
                ),
              ),
            ],
          ),
          child: SelectableText(error.fingerprintString),
        ),
        const SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            FButton(
              variant: .outline,
              onPress: close,
              child: Text('close'.tr()),
            ),
            const Spacer(),
            FButton(
              variant: .outline,
              onPress: () => onRetry?.call(skipHostKeyVerification: true),
              child: Text('hosts_update_fingerprint_accept'.tr()),
            ),
            FButton(
              onPress: () async {
                await ref
                    .read(sessionProvider.notifier)
                    .acceptFingerprint(
                      session.connection.vaultId,
                      session.id,
                      error,
                    );
                onRetry?.call();
              },
              child: Text('hosts_update_fingerprint_save_accept'.tr()),
            ),
          ],
        ),
      ];
    }

    buildError(String message) {
      return [
        const Icon(LucideIcons.plugZap, size: 48),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(
            children: TextUtils.renderText(
              context,
              'hosts_failed_to_connect_to'.tr(
                args: [session.connection.addressAndPort],
              ),
            ),
          ),
          style: typography.body.xl,
        ),
        const SizedBox(height: 16),
        Row(
          children: [Expanded(child: ErrorCard(text: message))],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            FButton(
              variant: .outline,
              onPress: close,
              child: Text('close'.tr()),
            ),
            FButton(onPress: () => onRetry?.call(), child: Text('retry'.tr())),
          ],
        ),
      ];
    }

    if (session.status is SessionConnected) return builder(context);

    final List<Widget> children = switch (session.status) {
      SessionConnecting() => buildConnecting(),
      SessionNeedsHostTrust(:final error) => buildKnownHostError(error),
      SessionFailed(:final message) => buildError(message),
      SessionConnected() => const [],
    };

    const verticalPadding = 20.0;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: verticalPadding),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - (verticalPadding * 2),
            ),
            child: Center(
              child: CliqGridContainer(
                alignment: .center,
                children: [
                  CliqGridRow(
                    children: [
                      CliqGridColumn(
                        sizes: const {.md: 6},
                        child: Column(
                          mainAxisSize: .min,
                          crossAxisAlignment: .center,
                          children: children,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
