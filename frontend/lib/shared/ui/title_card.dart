import 'package:flutter/widgets.dart';

import 'package:forui/forui.dart';

class TitleCard extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? child;

  const new({this.title, this.subtitle, this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final style = context.theme.cardStyle;
    return FCard(
      style: style,
      child: Padding(
        padding: style.padding,
        child: Column(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            if (title != null) ...[
              DefaultTextStyle.merge(
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: style.titleTextStyle,
                child: title!,
              ),
              const SizedBox(height: 2),
            ],
            if (subtitle != null) ...[
              DefaultTextStyle.merge(
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: false,
                  applyHeightToLastDescent: false,
                ),
                style: style.subtitleTextStyle,
                child: subtitle!,
              ),
              const SizedBox(height: 6),
            ],
            ?child,
          ],
        ),
      ),
    );
  }
}
