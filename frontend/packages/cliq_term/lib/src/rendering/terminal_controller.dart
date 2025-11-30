import 'package:cliq_term/src/model/terminal_buffer.dart';
import 'package:cliq_term/src/parser/escape_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

import '../model/cell.dart';
import '../model/formatting_options.dart';

class TerminalController extends ChangeNotifier {
  static final Logger _log = Logger('TerminalController');

  int rows;
  int cols;
  int cursorRow = 0;
  int cursorCol = 0;

  FormattingOptions curFmt = FormattingOptions();

  late TerminalBuffer front;
  late TerminalBuffer back;

  void Function(String)? onInput;
  final void Function(int, int)? onResize;
  final void Function(String)? onTitleChange;
  final void Function()? onBell;

  TerminalController({
    required this.rows,
    required this.cols,
    this.onResize,
    this.onTitleChange,
    this.onBell,
  }) {
    front = TerminalBuffer(rows, cols);
    back = TerminalBuffer(rows, cols);
  }

  void resize(int newRows, int newCols) {
    if (newRows == rows && newCols == cols) return;
    onResize?.call(newRows, newCols);

    rows = newRows;
    cols = newCols;
    front = front.resize(newRows, newCols);
    back = back.resize(newRows, newCols);

    cursorRow = cursorRow.clamp(0, rows - 1);
    cursorCol = cursorCol.clamp(0, cols - 1);
    notifyListeners();
  }

  void handleKey(KeyEvent ev) {
    if (ev is! KeyDownEvent) return;

    final String? ch = ev.character;
    if (ch != null && ch.isNotEmpty) {
      onInput?.call(ch);
      return;
    }

    final key = ev.logicalKey;
    if (key == LogicalKeyboardKey.enter) {
      onInput?.call('\n');
    } else if (key == LogicalKeyboardKey.backspace) {
      onInput?.call('\x7f');
    } else if (key == LogicalKeyboardKey.tab) {
      onInput?.call('\t');
    } else if (key == LogicalKeyboardKey.arrowUp) {
      onInput?.call('\x1b[A');
    } else if (key == LogicalKeyboardKey.arrowDown) {
      onInput?.call('\x1b[B');
    } else if (key == LogicalKeyboardKey.arrowRight) {
      onInput?.call('\x1b[C');
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      onInput?.call('\x1b[D');
    }
  }

  /// Resets both front and back buffers, cursor position, and formatting.
  void resetBuffers() {
    front.clear();
    back.clear();
    cursorRow = 0;
    cursorCol = 0;
    curFmt.reset();
    notifyListeners();
  }

  /// Swaps the front and back buffers, clearing the new back buffer.
  void commitToBackBuffer() {
    front.clear();
    back.clear(); // keep back empty/consistent
    resetScrollback();
    notifyListeners();
  }

  void _writeChar(String ch) {
    if (rows == 0 || cols == 0) return;

    if (cursorRow < 0) cursorRow = 0;
    if (cursorCol < 0) cursorCol = 0;

    if (cursorCol >= cols) {
      cursorCol = 0;
      cursorRow++;
    }

    front.setCell(cursorRow, cursorCol, Cell(ch, FormattingOptions.clone(curFmt)));
    cursorCol++;

    if (cursorCol >= cols) {
      cursorCol = 0;
      cursorRow++;
      if (cursorRow >= rows) {
        // scroll front up one line
        front.pushEmptyLine();
        cursorRow = rows - 1;
      }
    }
  }

  void resetScrollback() {
    // TODO: implement
  }

  void feed(String input) {
    int i = 0;
    final len = input.length;
    while (i < len) {
      final ch = input[i];

      if (ch == '\x1B') {
        if (i + 1 >= len) break;
        final next = input[i + 1];

        if (next == '[') {
          final consumed = EscapeParser.parse(this, input, i + 1, curFmt);
          if (consumed <= 0) break;
          i += 1 + consumed;
          continue;
        }

        if (next == ']') {
          int j = i + 2;
          int contentStart = j;
          bool terminated = false;
          while (j < len) {
            final cu = input.codeUnitAt(j);
            if (cu == 0x07) {
              // BEL
              terminated = true;
              break;
            }
            if (cu == 0x1B && j + 1 < len && input.codeUnitAt(j + 1) == 0x5C) {
              // ESC '\'
              terminated = true;
              break;
            }
            j++;
          }
          if (!terminated) break; // incomplete OSC
          final contentEnd = j;
          final payload = input.substring(contentStart, contentEnd);
          final parts = payload.split(';');
          final title = parts.length >= 2
              ? parts.sublist(1).join(';')
              : payload;
          if (title.isNotEmpty) onTitleChange?.call(title);
          // advance past terminator (BEL) or ESC '\'
          i = input.codeUnitAt(j) == 0x07 ? j + 1 : j + 2;
          continue;
        }

        _log.warning('Unknown ESC sequence: \\x1B$next');
        i++;
        continue;
      }

      final cu = ch.codeUnitAt(0);
      // BEL
      if (cu == 0x07) {
        onBell?.call();
        i++;
        continue;
      }
      // CR
      if (cu == 0x0D) {
        cursorCol = 0;
        i++;
        continue;
      }
      // LF
      if (cu == 0x0A) {
        cursorRow = cursorRow + 1;
        if (cursorRow >= rows) {
          front.pushEmptyLine();
          cursorRow = rows - 1;
        }
        cursorCol = 0;
        i++;
        continue;
      }
      // TAB
      if (cu == 0x09) {
        _writeChar('\t');
        i++;
        continue;
      }

      if (cu < 0x20) {
        _log.fine('Ignoring control character: 0x${cu.toRadixString(16)}');
        i++;
        continue;
      }

      _writeChar(ch);
      i++;
    }

    resetScrollback();
    notifyListeners();
  }
}
