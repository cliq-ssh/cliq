import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CliqTileGroup extends StatelessWidget {
  final List<CliqTile> children;
  final Widget? label;
  final CliqTileGroupStyle? style;

  const CliqTileGroup({
    super.key,
    required this.children,
    this.label,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.tileGroupStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CliqDefaultTypography(
              size: context.theme.typography.copyS,
              color: style.iconTheme.color,
              child: label!,
            ),
          ),
        ],
        // TODO: fix border radius issues
        CliqBlurContainer(
          borderRadius: style.borderRadius,
          child: Column(
            children: [
              for (final tile in children)
                CliqTile(
                  title: tile.title,
                  subtitle: tile.subtitle,
                  leading: tile.leading,
                  trailing: tile.trailing,
                  onPressed: tile.onPressed,
                  disabled: tile.disabled,
                  style: (tile.style ?? context.theme.tileStyle).copyWith(
                    outlineColor: Colors.transparent,
                    borderRadius: BorderRadius.zero,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

final class CliqTileGroupStyle {
  final IconThemeData iconTheme;
  final BorderRadius borderRadius;

  const CliqTileGroupStyle({required this.iconTheme, required this.borderRadius});

  factory CliqTileGroupStyle.inherit({
    required CliqStyle style,
    required CliqColorScheme colorScheme,
  }) {
    return CliqTileGroupStyle(
      iconTheme: IconThemeData(
        color: colorScheme.onSecondaryBackground,
        size: 20,
      ),
      borderRadius: BorderRadius.all(Radius.circular(16)),
    );
  }
}
