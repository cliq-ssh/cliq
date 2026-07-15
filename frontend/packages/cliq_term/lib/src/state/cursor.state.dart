import 'dart:async';

import '../../cliq_term.dart';

class CursorState {
  static const minCursorBlinkInterval = 100;
  static const maxCursorBlinkInterval = 2000;

  static const minCursorBlinkTimeout = 0;
  static const maxCursorBlinkTimeout = 3600;

  final CursorStyle style;

  /// Whether the cursor is enabled (visible) in the terminal (DECTCEM).
  final bool enabled;

  /// Whether the cursor is currently in the "on" phase of blinking.
  final bool blinkVisible;

  final Timer? timer;
  final Timer? inactivityTimer;

  CursorState({
    this.style = CursorStyle.bar,
    this.enabled = true,
    this.blinkVisible = true,
    this.timer,
    this.inactivityTimer,
  });

  CursorState copyWith({
    CursorStyle? style,
    bool? enabled,
    bool? blinkVisible,
    Timer? timer,
    Timer? inactivityTimer,
  }) {
    return CursorState(
      style: style ?? this.style,
      enabled: enabled ?? this.enabled,
      blinkVisible: blinkVisible ?? this.blinkVisible,
      timer: timer ?? this.timer,
      inactivityTimer: inactivityTimer ?? this.inactivityTimer,
    );
  }
}
