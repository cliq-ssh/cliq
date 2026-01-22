import 'package:flutter/cupertino.dart';

extension TextControllerExtension on TextEditingController {
  String? get textOrNull {
    final trimmed = text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
