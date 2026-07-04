import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

class LocalizedException implements Exception {
  final String key;

  const LocalizedException(this.key);

  String tr(BuildContext context) => key.tr();
}
