import 'package:cliq_ui/cliq_ui.dart' show CliqFontFamily;
import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

import '../../../shared/provider/store.provider.dart';
import '../../../shared/ui/navigation_shell.dart';
import '../../connections/provider/connection.provider.dart';
import '../../settings/provider/terminal_theme.provider.dart';
import '../provider/session.provider.dart';
import '../view/session_page.dart';

class SessionTitleBar extends HookConsumerWidget {
  final String sessionId;
  final bool hovered;

  const SessionTitleBar({
    super.key,
    required this.sessionId,
    this.hovered = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themes = ref.watch(terminalThemeProvider);
    final defaultTerminalThemeId = useStore(.defaultTerminalThemeId);

    final backgroundColor = useState<Color?>(null);
    final foregroundColor = useState<Color?>(null);

    final session = ref.read(sessionProvider.notifier).findById(sessionId);

    // read connection again since it might have been updated
    final connection = ref
        .watch(connectionProvider.notifier)
        .findById(session.connection.id)!;

    final effectiveTerminalTheme = session.connection.getEffectiveTerminalTheme(
      themes,
      defaultTerminalThemeId.value,
    );

    useEffect(() {
      if (!session.isConnected) {
        backgroundColor.value = null;
        foregroundColor.value = null;
        return;
      }

      backgroundColor.value = effectiveTerminalTheme.backgroundColor;
      foregroundColor.value = effectiveTerminalTheme.foregroundColor;
      return null;
    }, [effectiveTerminalTheme, session]);

    buildButton({
      required IconData icon,
      required VoidCallback onPress,
      String? label,
    }) {
      final child = FTappable(
        onPress: onPress,
        child: Icon(icon, size: 16, color: foregroundColor.value),
      );

      if (label == null) {
        return child;
      }

      return FTooltip(tipBuilder: (_, _) => Text(label), child: child);
    }

    return Container(
      color: backgroundColor.value ?? context.theme.colors.background,
      child: Padding(
        padding: const .only(
          top: kShellSessionPagePadding,
          left: kShellSessionPagePadding,
          right: kShellSessionPagePadding,
        ),
        child: Row(
          spacing: 8,
          crossAxisAlignment: .center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: connection.iconBackgroundColor,
                borderRadius: BorderRadius.circular(6),
              ),
              padding: .all(4),
              child: Icon(
                connection.icon.iconData,
                color: connection.iconColor,
                size: 10,
              ),
            ),
            Text(
              connection.label,
              style: context.theme.typography.body.xs2.copyWith(
                fontFamily: CliqFontFamily.secondary.fontFamily,
                color: foregroundColor.value ?? context.theme.colors.foreground,
              ),
            ),
            const Spacer(),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: hovered ? 1 : 0,
              child: Row(
                spacing: 8,
                children: [
                  buildButton(
                    icon: LucideIcons.x,
                    onPress: () {
                      ref
                          .read(sessionProvider.notifier)
                          .closeSessionAndMaybeGo(
                            NavigationShell.of(context),
                            session.id,
                          );
                    },
                    label: 'Close',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
