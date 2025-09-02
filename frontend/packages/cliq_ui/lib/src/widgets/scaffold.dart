import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CliqScaffold extends StatelessWidget {
  final Widget body;
  final Widget? header;
  final Widget? footer;
  final bool extendBehindAppBar;
  final bool safeAreaTop;
  final CliqScaffoldStyle? style;

  const CliqScaffold({
    super.key,
    required this.body,
    this.header,
    this.footer,
    this.extendBehindAppBar = false,
    this.safeAreaTop = true,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.scaffoldStyle;

    buildDefaultLayout() {
      return [?header, Expanded(child: body), ?footer];
    }

    buildExtendedLayout() {
      return [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(child: body),
              if (header != null)
                Positioned(left: 0, right: 0, top: 0, child: header!),
              if (footer != null)
                Positioned(left: 0, right: 0, bottom: 0, child: footer!),
            ],
          ),
        ),
      ];
    }

    return ColoredBox(
      color: style.backgroundColor,
      child: SafeArea(
        top: safeAreaTop,
        bottom: false,
        left: false,
        right: false,
        child: IconTheme(
          data: style.iconStyle,
          child: Column(
            children: [
              ...(extendBehindAppBar
                  ? buildExtendedLayout()
                  : buildDefaultLayout()),
            ],
          ),
        ),
      ),
    );
  }
}

final class CliqScaffoldStyle {
  final Color backgroundColor;
  final IconThemeData iconStyle;

  const CliqScaffoldStyle({
    required this.backgroundColor,
    required this.iconStyle,
  });

  factory CliqScaffoldStyle.inherit({required CliqColorScheme colorScheme}) {
    return CliqScaffoldStyle(
      backgroundColor: colorScheme.background,
      iconStyle: IconThemeData(color: colorScheme.onBackground),
    );
  }
}
