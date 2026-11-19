import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/session/model/tab.model.dart';
import 'package:cliq/modules/session/provider/session.provider.dart';
import 'package:cliq/modules/session/provider/tab.provider.dart';
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

class GenericSessionPage extends HookConsumerWidget {
  final Widget child;
  final Tab tab;
  final SshSession session;
  final bool isConnected;
  final bool isLikelyLoading;
  final void Function({bool skipHostKeyVerification})? onRetry;

  const new({
    super.key,
    required this.child,
    required this.tab,
    required this.session,
    required this.isConnected,
    required this.isLikelyLoading,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.theme.typography;

    close() {
      ref.read(tabProvider.notifier).close(tab.id);
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

    buildKnownHostWarning() {
      return [
        const Icon(LucideIcons.fingerprintPattern, size: 48),
        const SizedBox(height: 16),
        Text.rich(
          textAlign: .center,
          TextSpan(
            children: TextUtils.renderText(
              context,
              (session.knownHostError!.knownHost != null
                      ? 'hosts_update_fingerprint_title'
                      : 'hosts_accept_fingerprint_title')
                  .tr(args: [session.knownHostError!.host]),
            ),
          ),
          style: typography.body.xl,
        ),
        if (session.knownHostError!.knownHost != null)
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
              Text('${session.knownHostError!.algorithm} (SHA256)'),
              CliqTooltip(
                text: Text('click_to_copy'.tr()),
                child: FButton.icon(
                  onPress: () => Commons.copyToClipboard(
                    context,
                    session.knownHostError!.fingerprintString,
                  ),
                  child: const Icon(LucideIcons.copy, size: 14),
                ),
              ),
            ],
          ),
          child: SelectableText(session.knownHostError!.fingerprintString),
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
                      session.knownHostError!,
                    );
                onRetry?.call();
              },
              child: Text('hosts_update_fingerprint_save_accept'.tr()),
            ),
          ],
        ),
      ];
    }

    buildError() {
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
        if (session.connectionError != null)
          Row(
            children: [
              Expanded(child: ErrorCard(text: session.connectionError!)),
            ],
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

    if (isConnected) {
      return child;
    }

    List<Widget> children = [];
    if (session.knownHostError != null) {
      children = buildKnownHostWarning();
    } else if (session.connectionError != null) {
      children = buildError();
    } else if (isLikelyLoading) {
      children = buildConnecting();
    }

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
