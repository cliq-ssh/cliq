import '../../../cliq_term.dart';

class Cell(var String ch, var FormattingOptions fmt) {
  static const String emptyChar = ' ';

  Cell.empty() : this(emptyChar, .defaultFormat);
  Cell.clone(Cell other) : this(other.ch, .clone(other.fmt));

  void reset() {
    ch = emptyChar;
    fmt = .defaultFormat;
  }
}
