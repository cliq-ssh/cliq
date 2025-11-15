import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/routing/view/navigation_shell.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../modules/session/provider/session.provider.dart';

class SessionTab extends StatefulHookConsumerWidget {
  final ShellSession session;
  final bool isSelected;

  const SessionTab({
    super.key,
    required this.session,
    this.isSelected = false,
  });

  @override
  ConsumerState<SessionTab> createState() => _SessionTabState();
}

class _SessionTabState extends ConsumerState<SessionTab> {
  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final isHovered = useState(false);

    buildIcon() {
      if (isHovered.value) {
        return GestureDetector(
          onTap: () => ref
              .read(sessionProvider.notifier)
              .closeSession(NavigationShell.of(context), widget.session.id),
          child: Icon(LucideIcons.x, color: colors.destructive),
        );
      }
      if (widget.session.isLikelyLoading) {
        return FCircularProgress();
      }
      if (widget.session.isConnected) {
        // TODO: space for terminal icon
        return Icon(LucideIcons.terminal);
      }
      if (widget.session.connectionError != null) {
        return Icon(LucideIcons.plugZap, color: colors.destructive);
      }
      return null;
    }

    return MouseRegion(
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      cursor: SystemMouseCursors.click,
      child: FBadge(
        style: widget.isSelected
            ? FBadgeStyle.primary()
            : FBadgeStyle.outline(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            spacing: 8,
            children: [?buildIcon(), Text(widget.session.effectiveName)],
          ),
        ),
      ),
    );
  }
}
