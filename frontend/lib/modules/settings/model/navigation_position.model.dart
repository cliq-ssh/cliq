import 'package:flutter/cupertino.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

enum NavigationPosition {
  top,
  left;

  String getDisplayName(BuildContext context) {
    // TODO localization
    return switch (this) {
      NavigationPosition.top => 'Top',
      NavigationPosition.left => 'Left',
    };
  }

  IconData get icon {
    return switch (this) {
      NavigationPosition.top => LucideIcons.panelTop,
      NavigationPosition.left => LucideIcons.panelLeft,
    };
  }
}
