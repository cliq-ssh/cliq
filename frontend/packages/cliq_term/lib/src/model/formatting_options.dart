import 'package:cliq_term/src/model/color.dart';

enum Underline { none, single, double }

class FormattingOptions {
  late Color fgColor;
  late Color bgColor;
  late bool bold;
  late bool faint;
  late bool italic;
  late Underline underline;
  late bool concealed;

  FormattingOptions() {
    reset();
  }

  void reset() {
    fgColor = Color(0, ColorType.defaultColor);
    bgColor = Color(1, ColorType.defaultColor);
    bold = false;
    faint = false;
    italic = false;
    underline = Underline.none;
    concealed = false;
  }
}
