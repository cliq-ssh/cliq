import 'package:cliq_term/src/rendering/model/formatting_options.model.dart';

class Cell {
  static const String emptyChar = ' ';

  String ch;
  FormattingOptions fmt;

  Cell(this.ch, this.fmt);

  Cell.empty() : ch = Cell.emptyChar, fmt = FormattingOptions.defaultFormat;

  Cell.clone(Cell other)
    : ch = other.ch,
      fmt = FormattingOptions.clone(other.fmt);

  void reset() {
    ch = Cell.emptyChar;
    fmt = FormattingOptions.defaultFormat;
  }
}
