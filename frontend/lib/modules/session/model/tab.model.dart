import 'package:cliq/modules/session/model/session.model.dart';
import 'package:cliq/modules/settings/model/terminal_theme.state.dart';
import 'package:flutter/cupertino.dart';
import 'package:forui/forui.dart';

class SessionTab {
  /// Unique identifier for the session tab, used for tracking and state management.
  final String id;

  /// The root session for this tab.
  final ShellSession root;

  /// The list of sessions contained in this tab, including the root and any additional sessions from splits.
  final List<ShellSession> sessions;

  /// Optional custom label for the tab. If null, the UI will fall back to the connection label or a
  /// generated label based on number of sessions.
  final String? label;

  const SessionTab({
    required this.id,
    required this.root,
    required this.sessions,
    this.label,
  });

  const SessionTab.create({required this.id, required this.root, this.label})
    : sessions = const [];

  void dispose() {
    for (final session in [...sessions, root]) {
      session.dispose();
    }
  }

  String get rootSessionId => root.id;
  bool get isAnyConnected => [...sessions, root].any((s) => s.isConnected);

  Color getEffectiveSidebarColor(
    BuildContext context,
    CustomTerminalThemeState terminalThemes,
    int defaultTerminalTheme,
  ) {
    if (sessions.isEmpty) {
      final hsl = HSLColor.fromColor(
        (root.connection.terminalThemeOverride ??
                terminalThemes.findById(
                  defaultTerminalTheme,
                  isDefaultTheme: true,
                )!)
            .backgroundColor,
      );
      return hsl
          .withLightness((hsl.lightness - 0.02).clamp(0.0, 1.0))
          .toColor();
    }

    return context.theme.colors.background;
  }

  SessionTab copyWith({
    String? id,
    ShellSession? root,
    List<ShellSession>? sessions,
    String? label,
  }) {
    return SessionTab(
      id: id ?? this.id,
      root: root ?? this.root,
      sessions: sessions ?? this.sessions,
      label: label ?? this.label,
    );
  }
}
