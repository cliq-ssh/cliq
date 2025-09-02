import 'package:flutter/material.dart';

import 'package:cliq_ui/cliq_ui.dart';

class CliqProgressBar extends StatefulWidget {
  final double progress;
  final CliqProgressBarStyle? style;

  const CliqProgressBar({super.key, required this.progress, this.style});

  @override
  State<CliqProgressBar> createState() => _CliqProgressBarState();
}

class _CliqProgressBarState extends State<CliqProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _oldProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _oldProgress = widget.progress;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _setAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant CliqProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.progress != oldWidget.progress) {
      _oldProgress = oldWidget.progress;
      _setAnimation();
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setAnimation() {
    _animation = Tween<double>(
      begin: _oldProgress,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.bounceInOut));
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? context.theme.progressBarStyle;

    return SizedBox(
      height: style.height,
      child: Stack(
        children: [
          CliqBlurContainer(
            color: style.backgroundColor,
            borderRadius: style.borderRadius,
          ),
          AnimatedBuilder(
            animation: _animation,
            builder: (_, _) {
              return FractionallySizedBox(
                widthFactor: _animation.value,
                child: CliqBlurContainer(
                  color: style.progressColor,
                  borderRadius: style.borderRadius,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

final class CliqProgressBarStyle {
  final Color backgroundColor;
  final Color progressColor;
  final BorderRadiusGeometry borderRadius;
  final double height;

  const CliqProgressBarStyle({
    required this.backgroundColor,
    required this.progressColor,
    required this.borderRadius,
    required this.height,
  });

  factory CliqProgressBarStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    return CliqProgressBarStyle(
      backgroundColor: colorScheme.secondaryBackground,
      progressColor: colorScheme.primary,
      borderRadius: style.borderRadius,
      height: 16,
    );
  }
}
