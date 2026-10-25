import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:forui/forui.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

enum ListIconType { radio, checkbox }

class const ListIcon({
  super.key,
  final bool selected = false,
  final ListIconType type = .radio,
  final Color? color,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Icon(switch (type) {
      .radio => selected ? LucideIcons.circleCheck : LucideIcons.circle,
      .checkbox => selected ? LucideIcons.squareCheck : LucideIcons.square,
    }, color: color ?? context.theme.colors.mutedForeground);
  }
}
