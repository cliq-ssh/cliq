import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:cliq/shared/utils/text_utils.dart';
import 'package:cliq_ui/cliq_ui.dart'
    show CliqGridColumn, CliqGridContainer, CliqGridRow, CliqFontFamily;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' hide LicensePage;
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import '../../../shared/ui/navigation_shell.dart';
import '../provider/session.provider.dart';

class GenericSessionPage extends HookConsumerWidget {
  final Widget child;
  final ShellSession session;
  final bool isConnected;
  final bool isLikelyLoading;
  final void Function({bool skipHostKeyVerification})? onRetry;

  const GenericSessionPage({
    super.key,
    required this.child,
    required this.session,
    required this.isConnected,
    required this.isLikelyLoading,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = context.theme.typography;

    closeSession() {
      ref
          .read(sessionProvider.notifier)
          .closeSessionAndMaybeGo(NavigationShell.of(context), session.id);
    }

    buildConnecting() {
      return [
        FCircularProgress(),
        const SizedBox(height: 8),
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
        Icon(LucideIcons.fingerprintPattern, size: 48),
        const SizedBox(height: 8),
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
        FCard(
          subtitle: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text('${session.knownHostError!.algorithm} (SHA256)'),
              FTooltip(
                tipBuilder: (_, _) => Text('click_to_copy'.tr()),
                child: FButton.icon(
                  onPress: () => Commons.copyToClipboard(
                    context,
                    session.knownHostError!.fingerprintString,
                  ),
                  child: Icon(LucideIcons.copy, size: 14),
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
              onPress: closeSession,
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
        Icon(LucideIcons.plugZap, size: 48),
        const SizedBox(height: 8),
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
          FCard(
            style: .delta(
              decoration: .boxDelta(
                color: context.theme.colors.destructive.withValues(alpha: 0.1),
                border: Border.all(
                  color: context.theme.colors.destructive.withValues(
                    alpha: 0.2,
                  ),
                ),
              ),
            ),
            child: Text(
              session.connectionError!,
              style: context.theme.typography.body.xs.copyWith(
                fontFamily: CliqFontFamily.secondary.fontFamily,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            FButton(
              variant: .outline,
              onPress: closeSession,
              child: Text('close'.tr()),
            ),
            FButton(onPress: () => onRetry?.call(), child: Text('Retry')),
          ],
        ),
      ];
    }

    List<Widget> children = [];
    if (session.knownHostError != null) {
      children = buildKnownHostWarning();
    } else if (session.connectionError != null) {
      children = buildError();
    } else if (isLikelyLoading) {
      children = buildConnecting();
    } else if (isConnected) {
      return child;
    }

    return CliqGridContainer(
      alignment: .center,
      children: [
        CliqGridRow(
          children: [CliqGridColumn(child: Column(children: children))],
        ),
      ],
    );
  }
}
