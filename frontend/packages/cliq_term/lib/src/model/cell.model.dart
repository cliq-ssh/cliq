import '../../../cliq_term.dart';

class Cell {
  String ch;
  FormattingOptions fmt;

  Cell(this.ch, this.fmt);

  Cell.empty() : ch = ' ', fmt = FormattingOptions();

  Cell.clone(Cell other)
    : ch = other.ch,
      fmt = FormattingOptions.clone(other.fmt);
}
