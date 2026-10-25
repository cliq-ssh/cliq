import 'package:cliq_ui/cliq_ui.dart';
import 'package:material_ui/material_ui.dart';

class CliqBottomNavigationBar extends StatelessWidget {
  final List<CliqBottomNavigationBarItem> items;
  final int currentIndex;
  final Function(int)? onItemSelected;
  final CliqBottomNavigationBarStyle? style;

  const CliqBottomNavigationBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onItemSelected,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final style = this.style ?? context.theme.bottomNavigationBarStyle;
    final textStyle = context.theme.typography;

    buildItemButton(CliqBottomNavigationBarItem item, int index) {
      final bool isSelected = index == currentIndex;
      return CliqInteractable(
        onTap: () => onItemSelected?.call(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFFFFFF).withAlpha(70)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                if (item.icon != null)
                  ExcludeSemantics(
                    child: IconTheme(
                      data: isSelected
                          ? style.selectedIconStyle
                          : style.iconStyle,
                      child: item.icon!,
                    ),
                  ),
                if (isSelected) Text(item.label),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: CliqBlurContainer(
            borderRadius: BorderRadius.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: CliqDefaultTypography(
                size: textStyle.copyM,
                color: style.textColor,
                child: Row(
                  spacing: 8,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final item in items)
                      buildItemButton(item, items.indexOf(item)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

final class CliqBottomNavigationBarStyle {
  final Color color;
  final Color textColor;
  final IconThemeData iconStyle;
  final IconThemeData selectedIconStyle;

  const CliqBottomNavigationBarStyle({
    required this.color,
    required this.textColor,
    required this.iconStyle,
    required this.selectedIconStyle,
  });

  factory CliqBottomNavigationBarStyle.inherit({
    required CliqColorScheme colorScheme,
  }) {
    return CliqBottomNavigationBarStyle(
      color: colorScheme.secondaryBackground,
      textColor: colorScheme.onSecondaryBackground,
      iconStyle: IconThemeData(
        color: colorScheme.onSecondaryBackground,
        size: 24,
      ),
      selectedIconStyle: IconThemeData(
        color: colorScheme.onSecondaryBackground,
        size: 24,
      ),
    );
  }
}
