import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/cupertino.dart';

class CliqTile extends StatelessWidget {
  final Widget? title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Function()? onTap;
  final CliqTileStyle? style;

  const CliqTile({
    super.key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return CliqInteractable(
      onTap: onTap,
      child: CliqBlurContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          spacing: 16,
          children: [
            ?leading,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    CliqDefaultTypography(
                      size: context.theme.typography.copyS,
                      child: title!,
                    ),
                  if (subtitle != null)
                    CliqDefaultTypography(
                      size: context.theme.typography.copyS,
                      color: context.theme.colorScheme.onBackground70,
                      child: subtitle!,
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

final class CliqTileStyle {}
