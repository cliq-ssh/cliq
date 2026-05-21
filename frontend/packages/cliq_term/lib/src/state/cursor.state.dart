import 'dart:async';

import '../../cliq_term.dart';

class CursorState {
  final CursorStyle style;
  final bool visible;
  final Timer? timer;

  CursorState({
    this.style = .bar,
    this.visible = true,
    this.timer
  });

  CursorState copyWith({
    CursorStyle? style,
    bool? visible,
    Timer? timer
  }) {
    return CursorState(
      style: style ?? this.style,
      visible: visible ?? this.visible,
      timer: timer ?? this.timer
    );
  }
}
