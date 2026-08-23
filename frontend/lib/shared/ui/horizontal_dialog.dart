import 'package:flutter/widgets.dart';

import 'package:forui/forui.dart';

class HorizontalDialog extends StatelessWidget {
  final FDialogStyleDelta style;
  final Animation<double>? animation;
  final Widget? title;
  final Widget? subtitle;
  final Widget body;
  final List<Widget> actions;
  final BoxConstraints? constraints;

  const new({
    this.title,
    this.subtitle,
    required this.body,
    required this.actions,
    this.style = const .context(),
    this.animation,
    this.constraints,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FDialog(
      style: style,
      animation: animation,
      resizeToAvoidInsets: false,
      constraints:
          constraints ?? const BoxConstraints(minWidth: 280, maxWidth: 560),
      builder: (context, style) {
        final touch = context.platformVariant.touch;
        return Padding(
          padding: touch
              ? const .symmetric(horizontal: 16, vertical: 18)
              : const .symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisSize: .min,
            children: [
              if (title != null)
                Padding(
                  padding: touch
                      ? const .only(left: 8, right: 8, bottom: 9)
                      : const .only(bottom: 5),
                  child: DefaultTextStyle.merge(
                    style: style.titleTextStyle,
                    child: title!,
                  ),
                ),
              Flexible(
                child: Padding(
                  padding: touch
                      ? const .only(left: 8, right: 8, bottom: 20)
                      : const .only(bottom: 16),
                  child: DefaultTextStyle.merge(
                    style: style.bodyTextStyle,
                    child: body,
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: .end,
                spacing: touch ? 10 : 8,
                children: touch
                    ? [for (final action in actions) Expanded(child: action)]
                    : actions,
              ),
            ],
          ),
        );
      },
    );
  }
}
