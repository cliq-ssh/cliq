/// Contains some common escape sequences for terminal control.
class EscapeSequences {
  const EscapeSequences._();

  static const String tab = '\x09';

  static const String cursorUp = '\x1b[A';
  static const String cursorDown = '\x1b[B';
  static const String cursorRight = '\x1b[C';
  static const String cursorLeft = '\x1b[D';
}
