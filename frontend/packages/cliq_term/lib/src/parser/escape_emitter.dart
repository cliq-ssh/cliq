import 'package:cliq_term/cliq_term.dart';

class EscapeEmitter {
  const EscapeEmitter._();

  /// Emitted on
  /// https://terminalguide.namepad.de/seq/csi_st-18/
  /// (Response) https://terminalguide.namepad.de/seq/csi_st-8/
  static String size(int rows, int cols) {
    return '$kSeqEscape[8;$rows;${cols}t';
  }

  /// Emitted on
  /// https://terminalguide.namepad.de/seq/csi_st-14/
  /// (Response) https://terminalguide.namepad.de/seq/csi_st-4
  static String sizeInPixels(int height, int width) {
    return '$kSeqEscape[4;$height;${width}t';
  }

  /// urxvt (1015) extended mouse report.
  /// - https://terminalguide.namepad.de/mode/p1015/
  static String urxvtMouseEvent(int cb, int col, int row) {
    return '$kSeqEscape[${cb + 32};$col;${row}M';
  }

  /// SGR (1006) extended mouse report.
  /// - https://terminalguide.namepad.de/mouse/
  static String sgrMouseEvent(int cb, int col, int row, {required bool press}) {
    return '$kSeqEscape[<$cb;$col;$row${press ? 'M' : 'm'}';
  }
}
