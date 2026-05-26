import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/parser/csi_parser.dart';
import 'package:logging/logging.dart';

import '../rendering/model/byte_queue.dart';

typedef EscHandler = void Function();
typedef CsiHandler = void Function(CsiParseResult parsed);
typedef CcHandler = void Function(TerminalBuffer buffer);

class EscapeParser {
  static final Logger _log = Logger('EscapeParser');

  final TerminalController controller;

  late final CsiParser _csiParser = CsiParser();
  final _queue = ByteQueue();

  EscapeParser({required this.controller});

  late final Map<int, CcHandler> _ccHandlers = {
    0x05: _ccAnswerback,
    0x07: (_) => controller.onBell?.call(),
    0x08: (buf) => buf.backspace(),
    0x09: (buf) => buf.horizontalTab(),
    0x0A: (buf) => buf.lineFeed(),
    0x0B: (buf) => buf.lineFeed(),
    0x0C: (buf) => buf.lineFeed(),
    0x0D: (buf) => buf.carriageReturn(),
    // 0x0E: (_) {}, // TODO Shift Out (SO)
    // 0x0F: (_) {}, // TODO Shift In (SI)

    // CAN and SUB; cancel the current escape sequence
    0x18: (_) {},
    0x1A: (_) {},
  };

  late final Map<int, EscHandler> _escHandlers = {
    0x36: _escBackIndex,
    0x37: _escSaveCursor,
    0x38: _escRestoreCursor,
    0x39: _escForwardIndex,
    0x44: _escIndex,
    0x4D: _escReverseIndex,
    0x45: _escNextLine,
    0x48: _escHorizontalTabSet,
  };

  late final Map<int, CsiHandler> _csiHandlers = {
    'A'.codeUnitAt(0): _csiCursorUp,
    'B'.codeUnitAt(0): _csiCursorDown,
    'C'.codeUnitAt(0): _csiCursorRight,
    'D'.codeUnitAt(0): _csiCursorLeft,
    // 'E'.codeUnitAt(0): _csiCursorNextLine,
    // 'F'.codeUnitAt(0): _csiCursorPrevLine,
    // 'G'.codeUnitAt(0): _csiCursorHorizontalPositionAbsolute,
    'H'.codeUnitAt(0): _csiSetCursorPosition,
    // 'I.codeUnitAt(0): _csiCursorHorizontalForwardTab,
    'J'.codeUnitAt(0): _csiEraseDisplay,
    'K'.codeUnitAt(0): _csiEraseLine,
    // 'L'.codeUnitAt(0): _csiInsertLine,
    // 'M'.codeUnitAt(0): _csiDeleteLine,
    'P'.codeUnitAt(0): _csiDeleteCharacter,
    // 'S'.codeUnitAt(0): _csiScrollUp,
    // 'T'.codeUnitAt(0): _csiScrollDown,
    'X'.codeUnitAt(0): _csiEraseCharacter,
    // 'Z'.codeUnitAt(0): _csiCursorHorizontalBackwardTab,
    // 'a'.codeUnitAt(0): _csiCursorHorizontalRelative,
    // 'b'.codeUnitAt(0): _csiRepeatPrevCharacter,
    // 'c'.codeUnitAt(0): _csiDeviceAttributes,
    'd'.codeUnitAt(0): _csiLinePositionAbsolute,
    // 'e'.codeUnitAt(0): _csiVerticalPosRelative,
    // 'f'.codeUnitAt(0): _csiSetCursorPosition,
    // 'g'.codeUnitAt(0): _csiTabClear,
    'h'.codeUnitAt(0): _csiSetMode,
    // 'i'.codeUnitAt(0): _csiMediaControl,
    'l'.codeUnitAt(0): _csiSetMode,
    'm'.codeUnitAt(0): _csiSelectGraphicRendition,
    // 'n'.codeUnitAt(0): _csiRequestReport,
    // 'p'.codeUnitAt(0): _csiRequestMode,
    // 'q'.codeUnitAt(0): _csiSelectCursorStyle,
    'r'.codeUnitAt(0): _csiSetScrollingRegion,
    // 's'.codeUnitAt(0): _csiSaveCursor,
    // 't'.codeUnitAt(0): _csiWindowManipulation,
    // 'u'.codeUnitAt(0): _csiRestoreCursor,
  };

  /// Feeds input into the parser.
  /// The input can contain any combination of printable characters, control characters, and escape sequences.
  void write(String input) {
    _queue.add(input);
    _process();
  }

  /// Processes the byte queue, handling control characters and escape sequences until more input is needed.
  void _process() {
    while (_queue.isNotEmpty) {
      final cu = _queue.peek();

      if (cu == 0x1B) {
        final saved = _queue.position;
        _queue.consume();
        if (!_processEscape()) {
          _queue.savePosition(saved);
          return;
        }
        continue;
      }

      _queue.consume();

      final ccHandler = _ccHandlers[cu];
      if (ccHandler != null) {
        ccHandler(controller.activeBuffer);
      } else if (cu >= 0x20) {
        controller.activeBuffer.printChar(cu);
      } else if (controller.debugLogging) {
        _log.warning('[CC] Unhandled 0x${cu.toRadixString(16)}');
      }
    }
  }

  /// Processes an escape sequence starting after the initial ESC.
  /// Returns true if a complete sequence was processed, false if more input is needed.
  bool _processEscape() {
    if (_queue.isEmpty) return false;

    final next = _queue.consume();

    // multi-byte ESC sequences
    if (next == 0x5B) return _consumeCsi(); // ESC [
    if (next == 0x5D) return _consumeOsc(); // ESC ]

    // single-char ESC sequences
    final handler = _escHandlers[next];
    if (handler != null) {
      handler();
    } else if (controller.debugLogging) {
      _log.warning('[ESC] Unhandled ESC ${String.fromCharCode(next)}');
    }
    return true;
  }

  /// Consumes a CSI sequence starting after the initial ESC [.
  bool _consumeCsi() {
    final start = _queue.position - 2;
    final buf = StringBuffer('[');

    while (_queue.isNotEmpty) {
      final cu = _queue.consume();

      if (cu == 0x18 || cu == 0x1A) return true; // CAN/SUB

      buf.writeCharCode(cu);

      if (cu >= 0x40 && cu <= 0x7E) {
        _dispatchCsi(buf.toString());
        return true;
      }
    }

    _queue.savePosition(start);
    return false;
  }

  /// Consumes an OSC sequence starting after the initial ESC ].
  bool _consumeOsc() {
    final start = _queue.position - 2;
    final buf = StringBuffer();

    while (_queue.isNotEmpty) {
      final cu = _queue.consume();

      if (cu == 0x18 || cu == 0x1A) return true; // CAN/SUB

      if (cu == 0x07) {
        // BEL
        _dispatchOsc(buf.toString());
        return true;
      }

      if (cu == 0x1B && _queue.isNotEmpty && _queue.peek() == 0x5C) {
        _queue.consume(); // consume ST backslash
        _dispatchOsc(buf.toString());
        return true;
      }

      buf.writeCharCode(cu);
    }

    _queue.savePosition(start);
    return false;
  }

  /// Dispatches a parsed CSI sequence to the appropriate handler based on the final byte.
  void _dispatchCsi(String body) {
    final parsed = _csiParser.parseCsi(body);
    final handler = _csiHandlers[parsed.finalByteCode];
    if (handler != null) {
      handler(parsed);
    } else {
      if (controller.debugLogging) {
        _log.warning(
          '\tUnimplemented CSI final=0x${parsed.finalByteCode.toRadixString(16)} (${String.fromCharCode(parsed.finalByteCode)}) body="$body"',
        );
      }
    }
  }

  /// Dispatches a parsed OSC sequence.
  void _dispatchOsc(String body) {
    // TODO: implement OSC handlers (title, icon name, etc.)
    if (controller.debugLogging) {
      _log.warning('[OSC] Unimplemented body="$body"');
    }
  }

  /// Utility to parse a single integer parameter from a CSI sequence, with an optional default value if the
  /// parameter is missing or empty.
  int _parseSingleParam(CsiParseResult parsed, {int defaultValue = 0}) {
    return parsed.params.isNotEmpty
        ? (parsed.params[0] ?? defaultValue)
        : defaultValue;
  }

  // --- Control Character Handlers ---

  void _ccAnswerback(TerminalBuffer buf) {
    final response = controller.answerback;
    if (response.isNotEmpty) controller.onInput?.call(response);
  }

  // --- ESC Handlers ---

  void _escBackIndex() => controller.activeBuffer.backIndex();
  void _escSaveCursor() => controller.activeBuffer.saveCursor();
  void _escRestoreCursor() => controller.activeBuffer.restoreCursor();
  void _escForwardIndex() => controller.activeBuffer.forwardIndex();
  void _escIndex() => controller.activeBuffer.index();
  void _escReverseIndex() => controller.activeBuffer.reverseIndex();
  void _escNextLine() => controller.activeBuffer.nextLine();
  void _escHorizontalTabSet() => controller.activeBuffer.horizontalTabSet();

  // --- CSI Handlers ---

  void _csiCursorUp(CsiParseResult parsed) {
    final amount = _parseSingleParam(parsed);
    controller.activeBuffer.cursorUp(amount);
  }

  void _csiCursorDown(CsiParseResult parsed) {
    final amount = _parseSingleParam(parsed);
    controller.activeBuffer.cursorDown(amount);
  }

  void _csiLinePositionAbsolute(CsiParseResult parsed) {
    final row = (parsed.params.isNotEmpty ? (parsed.params[0] ?? 1) : 1) - 1;
    controller.activeBuffer.setCursorPosition(
      row,
      controller.activeBuffer.cursorCol,
    );
  }

  void _csiEraseCharacter(CsiParseResult parsed) {
    final amount = _parseSingleParam(parsed, defaultValue: 1);
    final buf = controller.activeBuffer;
    for (
      var c = buf.cursorCol;
      c < min(buf.cursorCol + amount, controller.cols);
      c++
    ) {
      buf.setCell(buf.cursorRow, c, Cell.empty());
    }
  }

  void _csiCursorRight(CsiParseResult parsed) {
    final amount = _parseSingleParam(parsed);
    controller.activeBuffer.cursorRight(amount);
  }

  void _csiCursorLeft(CsiParseResult parsed) {
    final amount = _parseSingleParam(parsed);
    controller.activeBuffer.cursorLeft(amount);
  }

  void _csiSetCursorPosition(CsiParseResult parsed) {
    final row = (parsed.params.isNotEmpty ? (parsed.params[0] ?? 1) : 1) - 1;
    final col = (parsed.params.length >= 2 ? (parsed.params[1] ?? 1) : 1) - 1;
    controller.activeBuffer.setCursorPosition(row, col);
  }

  void _csiEraseDisplay(CsiParseResult parsed) {
    final mode = _parseSingleParam(parsed);
    switch (mode) {
      case 0:
        controller.activeBuffer.eraseDisplayBelow();
      case 1:
        controller.activeBuffer.eraseDisplayAbove();
      case 2:
        controller.activeBuffer.eraseDisplayComplete();
      case 3:
      // TODO: implement erase display scrollback
      // controller.activeBuffer.eraseDisplayScrollback();
      default:
        _log.warning('\tUnhandled ED mode: $mode');
    }
  }

  void _csiEraseLine(CsiParseResult parsed) {
    final mode = _parseSingleParam(parsed);
    switch (mode) {
      case 0:
        controller.activeBuffer.eraseLineRight();
      case 1:
        controller.activeBuffer.eraseLineLeft();
      case 2:
        controller.activeBuffer.eraseLineComplete();
      default:
        _log.warning('\tUnhandled EL mode: $mode');
    }
  }

  void _csiDeleteCharacter(CsiParseResult parsed) {
    final amount = _parseSingleParam(parsed);
    controller.activeBuffer.deleteCharacter(amount);
  }

  /// Set Mode (SM)
  /// - https://terminalguide.namepad.de/seq/csi_sh/
  /// - https://terminalguide.namepad.de/seq/csi_sh__p/
  ///
  /// Reset Mode (RM)
  /// - https://terminalguide.namepad.de/seq/csi_sl/
  /// - https://terminalguide.namepad.de/seq/csi_sl__p/
  void _csiSetMode(CsiParseResult parsed) {
    final enabled = parsed.finalByteCode == 'h'.codeUnitAt(0);
    final isPrivate = parsed.leader == '?';

    void handleMode(int mode) {
      switch (mode) {
        case 4:
          controller.setInsertMode(enabled);
          break;
        case 20:
          controller.setLineFeedMode(enabled);
          break;
        default:
          if (controller.debugLogging) {
            _log.warning('\tUnhandled mode set: $mode');
          }
          break;
      }
    }

    void handlePrivateMode(int mode) {
      switch (mode) {
        case 7:
          controller.setAutoWrapMode(enabled);
          break;
        case 1047:
        case 47:
          if (enabled) {
            controller.useBackBuffer(saveMainAndClear: false);
          } else {
            controller.useMainBuffer(restoreMain: false);
          }
          break;
        case 1049:
          if (enabled) {
            controller.useBackBuffer(saveMainAndClear: true);
          } else {
            controller.useMainBuffer(restoreMain: true);
          }
          break;
        default:
          if (controller.debugLogging) {
            _log.warning('\tUnhandled private mode set: $mode');
          }
          break;
      }
    }

    for (final p in parsed.params) {
      final mode = p ?? 0;
      if (isPrivate) {
        handlePrivateMode(mode);
      } else {
        handleMode(mode);
      }
    }
  }

  /// https://terminalguide.namepad.de/seq/csi_sm/
  void _csiSelectGraphicRendition(CsiParseResult parsed) {
    final formatting = controller.activeBuffer.currentFormat;

    final List<int> codes = parsed.params.isEmpty
        ? const <int>[0]
        : parsed.params.map((p) => p ?? 0).toList(growable: false);

    int offset = 0;
    while (offset < codes.length) {
      int code = codes[offset++];

      (switch (code) {
        0 => () => formatting.reset(),
        1 => () => formatting.bold = true,
        2 => () => formatting.faint = true,
        3 => () => formatting.italic = true,
        4 => () => formatting.underline = Underline.single,
        7 => () => formatting.inverted = true,
        8 => () => formatting.concealed = true,
        21 => () => formatting.underline = Underline.double,
        22 => () {
          formatting.bold = false;
          formatting.faint = false;
        },
        23 => () => formatting.italic = false,
        24 => () => formatting.underline = Underline.none,
        27 => () => formatting.inverted = false,
        28 => () => formatting.concealed = false,
        >= 30 && <= 37 => () => formatting.fgColor = ansi16ToColor(
          controller.theme,
          code - 30,
        ),
        38 => () {
          if (offset == codes.length) return;
          switch (codes[offset++]) {
            case 5:
              if (offset == codes.length) return;
              formatting.fgColor = xterm256ToColor(
                controller.theme,
                codes[offset],
              );
              break;
            case 2:
              if ((offset + 2) == codes.length) return;
              formatting.fgColor = rgbToColor(
                codes[offset - 3],
                codes[offset - 2],
                codes[offset - 1],
              );
            default:
              break;
          }
          // assume we consumed all the extra params
          offset = codes.length;
        },
        39 => () => formatting.fgColor = null,
        >= 40 && <= 47 => () => formatting.bgColor = ansi16ToColor(
          controller.theme,
          code - 40,
        ),
        48 => () {
          if (offset == codes.length) return;
          switch (codes[offset]) {
            case 5:
              if ((offset + 1) == codes.length) return;
              formatting.bgColor = xterm256ToColor(
                controller.theme,
                codes[offset + 1],
              );
              break;
            case 2:
              if ((offset + 3) == codes.length) return;
              formatting.bgColor = rgbToColor(
                codes[offset + 1],
                codes[offset + 2],
                codes[offset + 3],
              );
            default:
              break;
          }
          // assume we consumed all the extra params
          offset = codes.length;
        },
        49 => () => formatting.bgColor = null,
        >= 90 && <= 97 => () => formatting.fgColor = ansi16ToColor(
          controller.theme,
          (code - 90) + 8,
        ),
        >= 100 && <= 107 => () => formatting.bgColor = ansi16ToColor(
          controller.theme,
          (code - 100) + 8,
        ),
        _ => throw ArgumentError('Unhandled formatting code: $code'),
      }).call();
    }
  }

  void _csiSetScrollingRegion(CsiParseResult parsed) {
    final top = (parsed.params.isNotEmpty ? (parsed.params[0] ?? 1) : 1) - 1;
    final bottom =
        (parsed.params.length >= 2
            ? (parsed.params[1] ?? controller.rows)
            : controller.rows) -
        1;
    controller.activeBuffer.setVerticalMargins(top, bottom);
  }
}
