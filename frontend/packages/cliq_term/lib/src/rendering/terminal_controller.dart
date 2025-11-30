import 'dart:math';

import 'package:cliq_term/src/model/terminal_buffer.dart';
import 'package:cliq_term/src/parser/csi_parser.dart';
import 'package:cliq_term/src/parser/escape_parser.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../model/cell.dart';
import '../model/formatting_options.dart';

class TerminalController extends ChangeNotifier {
  int rows;
  int cols;

  int cursorRow = 0;
  int cursorCol = 0;

  FormattingOptions curFmt = FormattingOptions();

  late TerminalBuffer front;
  late TerminalBuffer back;

  void Function(String)? onInput;
  final void Function(int, int)? onResize;

  TerminalController({required this.rows, required this.cols, this.onResize}) {
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
    final String? ch = ev.character;
    if (ch != null && ch.isNotEmpty) {
      onInput?.call(ch);
      feed(ch);
      return;
    }

    final key = ev.logicalKey;
    if (key == LogicalKeyboardKey.enter) {
      onInput?.call('\n');
      feed('\n');
    } else if (key == LogicalKeyboardKey.backspace) {
      onInput?.call('\x7f');
    } else if (key == LogicalKeyboardKey.tab) {
      onInput?.call('\t');
      feed('\t');
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
    final tmp = front;
    front = back;
    back = tmp..clear();
    notifyListeners();
  }

  void _writeCharToBack(String ch) {
    if (cursorRow < 0 || cursorRow >= rows) return;
    if (cursorCol < 0 || cursorCol >= cols) return;
    back.setCell(
      cursorRow,
      cursorCol,
      Cell(ch, FormattingOptions.clone(curFmt)),
    );
    cursorCol++;
    if (cursorCol >= cols) {
      cursorCol = 0;
      cursorRow = (cursorRow + 1).clamp(0, rows - 1);
      // TODO: scroll up?
    }
  }

  void feed(String input) {
    int i = 0;
    while (i < input.length) {
      final ch = input[i];
      if (ch == '\x1B') {
        // ESC
        if (i + 1 < input.length) {
          final next = input[i + 1];
          if (next == '[') {
            final res = CSIParser.parse(input, i + 1);
            if (res == null) break;
            // handle
            if (res.finalByte == 'm') {
              EscapeParser.setFormattingFromArgs(res.params, curFmt);
            } else if (res.finalByte == 'J') {
              final mode = res.params.isEmpty
                  ? 0
                  : (res.params[0].isEmpty
                        ? 0
                        : int.tryParse(res.params[0]) ?? 0);
              if (mode == 2) {
                back.clear();
                cursorRow = 0;
                cursorCol = 0;
              }
            }
            i += res.consumed + 1;
            continue;
          }
        }
        i++;
        continue;
      }

      // control chars
      if (ch == '\r') {
        cursorCol = 0;
        i++;
        continue;
      }
      if (ch == '\n') {
        cursorRow = (cursorRow + 1).clamp(0, rows - 1);
        cursorCol = 0;
        i++;
        continue;
      }

      _writeCharToBack(ch);
      i++;
    }

    commitToBackBuffer();
  }
}
