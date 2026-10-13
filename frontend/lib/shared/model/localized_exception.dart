import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:easy_localization/easy_localization.dart';

class LocalizedException implements Exception {
  final String key;

  const new(this.key);

  String tr({BuildContext? context}) => key.tr(context: context);
}
