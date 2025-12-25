import 'package:cliq_term/cliq_term.dart';

class ControlCharacterParser {
  final TerminalController controller;

  ControlCharacterParser({required this.controller});

  late final Map<int, void Function()> _ccHandlers = {
    0x07: _ccBell,  // Bell
    0x08: _ccBackspace, // Backspace
    0x09: _ccHorizontalTab, // Horizontal Tab
    0x0A: _ccLineFeed, // Line Feed
    // 0x0B: () {}, // Vertical Tab
    // 0x0C: () {}, // Form Feed
    0x0D: _ccCarriageReturn, // Carriage Return
    // 0x0E: () {}, // Shift Out
    // 0x0F: () {}, // Shift In
    // 0x18: () {}, // Cancel Parsing CAN
    // 0x1A: () {}, // Cancel Parsing SUB
  };

  bool parseCc(int cu) {
    final handler = _ccHandlers[cu];
    if (handler != null) {
      handler();
      return true;
    }
    return false;
  }

  /// https://terminalguide.namepad.de/seq/a_c0-g/
  void _ccBell() {
    controller.onBell?.call();
  }

  /// https://terminalguide.namepad.de/seq/a_c0-h/
  void _ccBackspace() {
    if (controller.cursorCol > 0) {
      controller.cursorCol--;
      controller.front.setCell(controller.cursorRow, controller.cursorCol, Cell.empty());
    } else if (controller.cursorRow > 0) {
      controller.cursorRow--;
      int lastIdx = controller.cols - 1;
      while (lastIdx >= 0 && controller.front.getCell(controller.cursorRow, lastIdx).ch == ' ') {
        lastIdx--;
      }

      if (lastIdx < 0) {
        controller.cursorCol = 0;
      } else {
        controller.cursorCol = lastIdx;
        controller.front.setCell(controller.cursorRow, controller.cursorCol, Cell.empty());
      }
    }
  }

  /// https://terminalguide.namepad.de/seq/a_c0-i/
  void _ccHorizontalTab() {
    controller.writeChar('\t');
  }

  /// https://terminalguide.namepad.de/seq/a_c0-j/
  void _ccLineFeed() {
    controller.cursorRow++;
    if (controller.cursorRow >= controller.rows) {
      controller.front.pushEmptyLine();
      controller.cursorRow = controller.rows - 1;
    }
    controller.cursorCol = 0;
  }

  /// https://terminalguide.namepad.de/seq/a_c0-m/
  void _ccCarriageReturn() {
    controller.cursorCol = 0;
  }
}
