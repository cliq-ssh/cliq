import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/shared/ui/navigation_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../modules/session/provider/session.provider.dart';
import '../extensions/color.extension.dart';

class SessionTab extends StatefulHookConsumerWidget {
  final ShellSession session;

  const SessionTab({super.key, required this.session});

  @override
  ConsumerState<SessionTab> createState() => _SessionTabState();
}

class _SessionTabState extends ConsumerState<SessionTab> {
  @override
  Widget build(BuildContext context) {
    final typography = context.theme.typography;
    final colors = context.theme.colors;
    final isHovered = useState(false);
    final sessions = ref.watch(sessionProvider);
    final isSelected = useState(false);

    useEffect(() {
      isSelected.value = sessions.selectedSessionId == widget.session.id;
      return null;
    }, [sessions, sessions.selectedSessionId]);

    closeSession() {
      ref
          .read(sessionProvider.notifier)
          .closeSession(NavigationShell.of(context), widget.session.id);
    }

    buildIcon() {
      if (isHovered.value) {
        return FTooltip(
          tipBuilder: (_, _) => Text('Close'),
          child: GestureDetector(
            onTap: closeSession,
            child: Icon(LucideIcons.x, color: colors.destructive, size: 24),
          ),
        );
      }
      if (widget.session.isLikelyLoading) {
        return FCircularProgress();
      }
      if (widget.session.isConnected) {
        // TODO: space for terminal icon
        return Container(
          padding: const .all(6),
          decoration: BoxDecoration(
            color: widget.session.connection.color != null
                ? ColorExtension.fromHex(widget.session.connection.color!)
                : null,
            shape: .circle,
          ),
          child: Icon(
            widget.session.connection.icon.iconData,
            color: colors.foreground,
            size: 12,
          ),
        );
      }
      if (widget.session.connectionError != null) {
        return Icon(LucideIcons.plugZap, color: colors.destructive);
      }
      return null;
    }

    formatDuration(Duration duration) {
      if (duration.inHours > 0) {
        return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
      } else if (duration.inMinutes > 0) {
        return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
      } else {
        return '${duration.inSeconds}s';
      }
    }

    return GestureDetector(
      onTap: () => ref
          .read(sessionProvider.notifier)
          .setSelectedSession(NavigationShell.of(context), widget.session.id),
      onTertiaryTapUp: (details) {
        if (details.kind == .mouse) closeSession();
      },
      child: FTooltip(
        tipBuilder: (_, _) {
          return Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Text(
                widget.session.effectiveName,
                style: typography.lg.copyWith(fontWeight: .bold),
              ),
              if (widget.session.connection.groupName != null)
                Text(
                  widget.session.connection.groupName!,
                  style: typography.sm.copyWith(color: colors.mutedForeground),
                ),
              if (widget.session.isConnected) ...[
                Text(
                  '${formatDuration(DateTime.now().difference(widget.session.connectedAt!))} elapsed',
                  style: typography.sm.copyWith(color: colors.mutedForeground),
                ),
              ],
            ],
          );
        },
        child: MouseRegion(
          onEnter: (_) => isHovered.value = true,
          onExit: (_) => isHovered.value = false,
          cursor: SystemMouseCursors.click,
          child: FBadge(
            style: isSelected.value
                ? FBadgeStyle.primary()
                : FBadgeStyle.outline(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                spacing: 8,
                children: [?buildIcon(), Text(widget.session.effectiveName)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
