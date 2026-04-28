import 'package:flutter/cupertino.dart';

class LocalizedException implements Exception {
  final String key;

  const LocalizedException(this.key);

  String localize(BuildContext context) {
    // TODO:
    return key;
  }
}
