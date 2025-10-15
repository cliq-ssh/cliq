import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';

class CliqInteractable extends StatefulWidget {
  final Widget child;
  final double begin, end;
  final Duration beginDuration;
  final Duration endDuration;
  final Function()? onTap;
  final Function()? onTapDown;
  final Function(PointerEnterEvent)? onEnter;
  final Function(PointerExitEvent)? onExit;
  final MouseCursor? cursor;
  final Curve beginCurve;
  final Curve endCurve;
  final bool disableAnimation;

  const CliqInteractable({
    super.key,
    required this.child,
    this.onTap,
    this.onTapDown,
    this.onEnter,
    this.onExit,
    this.begin = 1.0,
    this.end = 0.93,
    this.beginDuration = const Duration(milliseconds: 20),
    this.endDuration = const Duration(milliseconds: 120),
    this.cursor,
    this.beginCurve = Curves.decelerate,
    this.endCurve = Curves.fastOutSlowIn,
    this.disableAnimation = false,
  });

  @override
  State<StatefulWidget> createState() => _CliqInteractableState();
}

class _CliqInteractableState extends State<CliqInteractable>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.endDuration,
      value: 1.0,
      reverseDuration: widget.beginDuration,
    );

    _animation = Tween(begin: widget.end, end: widget.begin).animate(
      CurvedAnimation(
        parent: _controller!,
        curve: widget.beginCurve,
        reverseCurve: widget.endCurve,
      ),
    );

    _controller?.forward();
  }

  @override
  void dispose() {
    _controller?.stop();
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.cursor ?? MouseCursor.defer,
      onEnter: widget.onEnter,
      onExit: widget.onExit,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Listener(
          onPointerDown: (c) async => _controller?.reverse(),
          onPointerUp: (c) async => await _controller?.forward(),
          child: widget.disableAnimation
              ? widget.child
              : ScaleTransition(scale: _animation, child: widget.child),
        ),
      ),
    );
  }
}
