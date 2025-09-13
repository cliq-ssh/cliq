import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_flutter/lucide_flutter.dart';

/// Class for common UI components used across the application that don't fit
/// into the cliq_ui library.
class Commons {
  const Commons._();

  static Widget backButton(BuildContext ctx) => CliqIconButton(
    icon: Icon(LucideIcons.arrowLeft),
    onPressed: () => ctx.pop(),
  );

  static Widget closeButton(BuildContext ctx) => CliqIconButton(
    icon: Icon(LucideIcons.x),
    onPressed: () => ctx.pop(),
  );
}
