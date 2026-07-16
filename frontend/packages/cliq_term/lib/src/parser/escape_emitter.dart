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
}
