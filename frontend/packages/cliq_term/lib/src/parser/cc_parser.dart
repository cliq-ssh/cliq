import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/rendering/model/terminal_buffer.dart';

typedef CcHandler = void Function(TerminalBuffer buf);

class ControlCharacterParser {
  final TerminalController controller;

  ControlCharacterParser({required this.controller});

  late final Map<int, CcHandler> _ccHandlers = {
    0x07: (_) => controller.onBell?.call(),
    0x08: (buf) => buf.backspace(),
    0x09: (buf) => buf.horizontalTab(),
    0x0A: (buf) => buf.lineFeed(),
    0x0B: (buf) => buf.lineFeed(),
    0x0C: (buf) => buf.lineFeed(),
    0x0D: (buf) => buf.carriageReturn(),
    // 0x0E: () {}, // Shift Out
    // 0x0F: () {}, // Shift In
    // 0x18: () {}, // Cancel Parsing CAN
    // 0x1A: () {}, // Cancel Parsing SUB
  };

  bool parseCc(int cu) {
    final handler = _ccHandlers[cu];
    if (handler != null) {
      handler(controller.activeBuffer);
      return true;
    }
    return false;
  }
}
