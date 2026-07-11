import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

enum NavigationPosition {
  top,
  left;

  String getDisplayName(BuildContext context) {
    return switch (this) {
      .top => 'appearance_navigation_position_top'.tr(),
      .left => 'appearance_navigation_position_left'.tr(),
    };
  }

  IconData get icon {
    return switch (this) {
      .top => LucideIcons.panelTop,
      .left => LucideIcons.panelLeft,
    };
  }
}
