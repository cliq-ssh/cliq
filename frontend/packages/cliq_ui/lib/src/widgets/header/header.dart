import 'package:cliq_ui/src/widgets/progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:cliq_ui/cliq_ui.dart';

part 'progress_header.dart';

class CliqHeader extends StatelessWidget {
  final Widget? title;
  final List<Widget>? left;
  final List<Widget>? right;
  final CliqAppBarStyle? style;

  const CliqHeader({super.key, this.title, this.left, this.right, this.style});

  const factory CliqHeader.progress({
    Key? key,
    List<Widget>? left,
    List<Widget>? right,
    CliqAppBarStyle? style,
    required double progress,
  }) = _CliqProgressHeader;

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.appBarStyle;
    final textStyle = context.theme.typography;

    align(Widget parent, Alignment align, bool isNull) {
      return Expanded(
        child: Align(
          alignment: align,
          child: isNull ? const SizedBox.shrink() : parent,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: style.verticalPagePadding),
      child: CliqGridContainer(
        children: [
          CliqGridRow(
            children: [
              CliqGridColumn(
                child: Row(
                  mainAxisAlignment:
                      (left != null && left!.isNotEmpty) || title != null
                      ? MainAxisAlignment.spaceBetween
                      : MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    align(
                      Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: left ?? [],
                      ),
                      Alignment.centerLeft,
                      left == null || left!.isEmpty,
                    ),
                    align(
                      CliqDefaultTypography(
                        size: textStyle.h4,
                        color: style.textColor,
                        fontFamily: CliqFontFamily.secondary,
                        child: title ?? const SizedBox.shrink(),
                      ),
                      Alignment.center,
                      title == null,
                    ),
                    align(
                      Row(
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: right ?? [],
                      ),
                      Alignment.centerRight,
                      right == null || right!.isEmpty,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

final class CliqAppBarStyle {
  final Color textColor;
  final double verticalPagePadding;

  const CliqAppBarStyle({
    required this.textColor,
    required this.verticalPagePadding,
  });

  factory CliqAppBarStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    return CliqAppBarStyle(
      textColor: colorScheme.onSecondaryBackground,
      verticalPagePadding: style.verticalPagePadding,
    );
  }
}
