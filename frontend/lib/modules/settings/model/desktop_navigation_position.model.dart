import 'package:flutter/cupertino.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

enum DesktopNavigationPosition {
  top,
  left;

  String getDisplayName(BuildContext context) {
    // TODO localization
    return switch (this) {
      DesktopNavigationPosition.top => 'Top',
      DesktopNavigationPosition.left => 'Left',
    };
  }

  IconData get icon {
    return switch (this) {
      DesktopNavigationPosition.top => LucideIcons.panelTop,
      DesktopNavigationPosition.left => LucideIcons.panelLeft,
    };
  }
}
