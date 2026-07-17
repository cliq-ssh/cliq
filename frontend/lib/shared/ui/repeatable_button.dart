import 'dart:async';
import 'package:flutter/material.dart';

class RepeatableButton extends StatefulWidget {
  /// The [onPress] callback is called immediately when the button is pressed.
  final VoidCallback onPress;

  /// The [child] widget is displayed inside the button.
  final Widget child;

  /// The [initialDelay] is the duration to wait before starting to repeat the [onPress] callback.
  final Duration initialDelay;

  /// The [repeatInterval] is the duration between each repeated call to the [onPress] callback.
  final Duration repeatInterval;

  const RepeatableButton({
    super.key,
    required this.onPress,
    required this.child,
    this.initialDelay = const .new(milliseconds: 400),
    this.repeatInterval = const .new(milliseconds: 80),
  });

  @override
  State<RepeatableButton> createState() => _RepeatableButtonState();
}

class _RepeatableButtonState extends State<RepeatableButton> {
  Timer? _initialTimer;
  Timer? _repeatTimer;

  void _start() {
    _initialTimer = Timer(widget.initialDelay, () {
      _repeatTimer = Timer.periodic(widget.repeatInterval, (_) {
        widget.onPress();
      });
    });
  }

  void _stop() {
    _initialTimer?.cancel();
    _repeatTimer?.cancel();
    _initialTimer = null;
    _repeatTimer = null;
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        widget.onPress(); // immediate feedback on first press
        _start();
      },
      onTapUp: (_) => _stop(),
      onTapCancel: () => _stop(),
      child: widget.child,
    );
  }
}
