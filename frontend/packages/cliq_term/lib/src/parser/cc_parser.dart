import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/model/terminal_buffer.dart';

typedef CcHandler = void Function(TerminalBuffer buf);

class ControlCharacterParser {
  final TerminalController controller;

  ControlCharacterParser({required this.controller});

  late final Map<int, CcHandler> _ccHandlers = {
    0x07: _ccBell, // Bell
    0x08: _ccBackspace, // Backspace
    0x09: _ccHorizontalTab, // Horizontal Tab
    0x0A: _ccLineFeed, // Line Feed
    0x0B: _ccLineFeed, // Vertical Tab
    0x0C: _ccLineFeed, // Form Feed
    0x0D: _ccCarriageReturn, // Carriage Return
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

  /// https://terminalguide.namepad.de/seq/a_c0-g/
  void _ccBell(TerminalBuffer buf) => controller.onBell?.call();

  /// https://terminalguide.namepad.de/seq/a_c0-h/
  void _ccBackspace(TerminalBuffer buf) => buf.backspace();

  /// https://terminalguide.namepad.de/seq/a_c0-i/
  void _ccHorizontalTab(TerminalBuffer buf) => buf.horizontalTab();

  /// https://terminalguide.namepad.de/seq/a_c0-j/
  void _ccLineFeed(TerminalBuffer buf) => buf.index();

  /// https://terminalguide.namepad.de/seq/a_c0-m/
  void _ccCarriageReturn(TerminalBuffer buf) => buf.carriageReturn();
}
