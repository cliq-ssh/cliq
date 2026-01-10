import 'package:cliq/shared/data/database.dart';
import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

class TerminalThemeCard extends HookConsumerWidget {
  final CustomTerminalTheme theme;
  final void Function()? onTap;
  final bool isSelected;

  const TerminalThemeCard({
    super.key,
    required this.theme,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    buildColor(Color color) {
      return Container(width: 8, height: 16, color: color);
    }

    return GestureDetector(
      onTap: onTap,
      child: FCard(
        title: Row(
          spacing: 16,
          mainAxisAlignment: .spaceBetween,
          children: [
            Column(
              crossAxisAlignment: .start,
              children: [
                Row(
                  children: [
                    theme.redColor,
                    theme.greenColor,
                    theme.yellowColor,
                    theme.blueColor,
                    theme.purpleColor,
                    theme.cyanColor,
                    theme.whiteColor,
                  ].map(buildColor).toList(),
                ),
                Row(
                  children: [
                    theme.brightRedColor,
                    theme.brightGreenColor,
                    theme.brightYellowColor,
                    theme.brightBlueColor,
                    theme.brightPurpleColor,
                    theme.brightCyanColor,
                    theme.brightWhiteColor,
                  ].map(buildColor).toList(),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: .start,
              children: [
                Text(theme.name),
                if (theme.id == -1 || theme.author != null)
                  Text(
                    theme.id == -1 ? 'built-in' : theme.author!,
                    style: context.theme.typography.xs.copyWith(
                      color: context.theme.colors.mutedForeground,
                      fontWeight: .normal,
                    ),
                  ),
              ],
            ),
            const Spacer(),
            if (isSelected) Icon(LucideIcons.check),
          ],
        ),
      ),
    );
  }
}
