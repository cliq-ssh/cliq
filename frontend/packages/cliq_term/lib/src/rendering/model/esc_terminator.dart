/// Types of escape sequence termination
enum EscTerminator {
  /// Terminated by the next character
  singleChar,

  /// Terminated by the final byte of a CSI sequence (0x40 to 0x7E)
  csi,

  /// Terminated by BEL (0x07) or ESC backslash
  osc,

  /// Terminated by ESC backslash
  escBackslash;

  static const int escCode = 0x1B;
  static const int belCode = 0x07;
  static const int backslashCode = 0x5C;
}
