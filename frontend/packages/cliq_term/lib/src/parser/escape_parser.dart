import 'dart:math';

import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/parser/csi_parser.dart';
import 'package:cliq_term/src/parser/escape_emitter.dart';
import 'package:logging/logging.dart';

import '../model/byte_queue.dart';

typedef EscHandler = void Function();
typedef CsiHandler = void Function(CsiParseResult parsed);
typedef OscHandler = void Function(String params);
typedef CcHandler = void Function(TerminalBuffer buffer);

class EscapeParser {
  static final Logger _log = Logger('EscapeParser');

  /// The maximum number of bytes to process in a single batch before yielding to the event loop.
  static const _maxByteChunkSize = 1000;

  /// The maximum time budget in milliseconds for processing a batch of bytes before yielding to the event loop.
  static const _maxTimeBudgetInMs = 4;

  final TerminalController controller;

  EscapeParser({required this.controller});

  late final CsiParser _csiParser = CsiParser();

  late final Map<int, CcHandler> _ccHandlers = {
    0x05: _ccAnswerback,
    0x07: (_) => controller.onBell?.call(),
    0x08: (buf) => buf.backspace(),
    0x09: (buf) => buf.horizontalTab(),
    0x0A: (buf) => buf.lineFeed(),
    0x0B: (buf) => buf.lineFeed(),
    0x0C: (buf) => buf.lineFeed(),
    0x0D: (buf) => buf.carriageReturn(),
    0x0E: (buf) => buf.charset.use(1),
    0x0F: (buf) => buf.charset.use(0),

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
    0x45: _escNextLine,
    0x48: _escHorizontalTabSet,
    0x4D: _escReverseIndex,
    0x4E: _escSingleShift2,
    0x4F: _escSingleShift3,
  };

  late final Map<int, CsiHandler> _csiHandlers = {
    '@'.codeUnitAt(0): _csiInsertBlanks,
    'A'.codeUnitAt(0): _csiCursorUp,
    'B'.codeUnitAt(0): _csiCursorDown,
    'C'.codeUnitAt(0): _csiCursorRight,
    'D'.codeUnitAt(0): _csiCursorLeft,
    // 'E'.codeUnitAt(0): _csiCursorNextLine,
    // 'F'.codeUnitAt(0): _csiCursorPrevLine,
    'G'.codeUnitAt(0): _csiCursorHorizontalAbsolute,
    'H'.codeUnitAt(0): _csiSetCursorPosition,
    // 'I.codeUnitAt(0): _csiCursorHorizontalForwardTab,
    'J'.codeUnitAt(0): _csiEraseDisplay,
    'K'.codeUnitAt(0): _csiEraseLine,
    'L'.codeUnitAt(0): _csiInsertLine,
    'M'.codeUnitAt(0): _csiDeleteLine,
    'P'.codeUnitAt(0): _csiDeleteCharacter,
    'S'.codeUnitAt(0): _csiScrollUp,
    'T'.codeUnitAt(0): _csiScrollDown,
    'X'.codeUnitAt(0): _csiEraseCharacter,
    // 'Z'.codeUnitAt(0): _csiCursorHorizontalBackwardTab,
    // 'a'.codeUnitAt(0): _csiCursorHorizontalRelative,
    // 'b'.codeUnitAt(0): _csiRepeatPrevCharacter,
    // 'c'.codeUnitAt(0): _csiDeviceAttributes,
    'd'.codeUnitAt(0): _csiLinePositionAbsolute,
    // 'e'.codeUnitAt(0): _csiVerticalPosRelative,
    'f'.codeUnitAt(0): _csiSetCursorPosition,
    // 'g'.codeUnitAt(0): _csiTabClear,
    'h'.codeUnitAt(0): _csiSetMode,
    // 'i'.codeUnitAt(0): _csiMediaControl,
    'l'.codeUnitAt(0): _csiSetMode,
    'm'.codeUnitAt(0): _csiSelectGraphicRendition,
    // 'n'.codeUnitAt(0): _csiRequestReport,
    // 'p'.codeUnitAt(0): _csiRequestMode,
    'q'.codeUnitAt(0): _csiSelectCursorStyle,
    'r'.codeUnitAt(0): _csiSetScrollingRegion,
    // 's'.codeUnitAt(0): _csiSaveCursor,
    't'.codeUnitAt(0): _csiWindowManipulation,
    // 'u'.codeUnitAt(0): _csiRestoreCursor,
  };

  late final Map<int, OscHandler> _oscHandlers = {
    0: _oscSetWindowTitle,
    2: _oscSetWindowTitle,
  };

  final _queue = ByteQueue();
  bool _isProcessing = false;

  int get queueLength => _queue.length;

  /// Feeds input into the parser.
  /// The input can contain any combination of printable characters, control characters, and escape sequences.
  void write(String input) {
    _queue.add(input);

    if (_queue.length > TerminalController.highWaterMark &&
        !controller.isPaused) {
      controller.pause();
    }

    if (!_isProcessing) {
      _process();
    }
  }

  /// Processes the queued input, parsing and dispatching control sequences and characters to the terminal controller.
  /// This method processes input in batches to avoid blocking the UI thread, yielding control back to the event loop
  /// if processing exceeds a time budget. ([_maxTimeBudgetInMs])
  void _process() {
    _isProcessing = true;
    final sw = Stopwatch()..start();

    while (_queue.isNotEmpty) {
      // Process in batches
      for (int i = 0; i < _maxByteChunkSize && _queue.isNotEmpty; i++) {
        final positionBefore = _queue.position;
        _processOne();

        if (_queue.position == positionBefore) {
          // An incomplete sequence is waiting on bytes that haven't arrived
          // yet. Stop here instead of spinning forever on the same input;
          // write() will resume processing once more data is fed.
          _isProcessing = false;
          controller.markDirty();
          return;
        }
      }

      // Budget of 4ms for parsing to keep UI fluid
      if (sw.elapsedMilliseconds >= _maxTimeBudgetInMs && _queue.isNotEmpty) {
        final wasPaused = controller.isPaused;
        controller.pause();
        _process();
        if (!wasPaused) controller.resume();
        controller.markDirty();
        return;
      }
    }

    _isProcessing = false;

    if (controller.isPaused &&
        _queue.length < TerminalController.lowWaterMark) {
      controller.resume();
    }
    controller.markDirty();
  }

  /// Processes a single byte from the queue, handling control characters, escape sequences, and printable characters.
  void _processOne() {
    final cu = _queue.peek();

    if (cu == 0x1B) {
      final saved = _queue.position;
      _queue.consume();
      if (!_processEscape()) {
        _queue.savePosition(saved);
        return;
      }
      return;
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

  /// Processes an escape sequence starting after the initial ESC.
  /// Returns true if a complete sequence was processed, false if more input is needed.
  bool _processEscape() {
    if (_queue.isEmpty) return false;
    final next = _queue.consume();

    // multi-byte ESC sequences
    if (next == 0x5B) return _consumeCsi(); // ESC [
    if (next == 0x5D) return _consumeOsc(); // ESC ]

    // G0 ('('), G1 (')'), G2 ('*'), G3 ('+') charset designation
    if (next == 0x28 || next == 0x29 || next == 0x2A || next == 0x2B) {
      if (_queue.isEmpty) return false;
      controller.activeBuffer.charset.designate(next - 0x28, _queue.consume());
      return true;
    }

    // single-char ESC sequences
    final handler = _escHandlers[next];
    if (handler != null) {
      handler();
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
    final splitIndex = body.indexOf(';');

    final String method;
    final String params;
    if (splitIndex == -1) {
      // Some OSC sequences are sent with no ';' separator at all when there are no parameters.
      method = body;
      params = '';
    } else {
      method = body.substring(0, splitIndex);
      params = body.substring(splitIndex + 1);
    }

    final code = int.tryParse(method);
    if (code == null) {
      if (controller.debugLogging) {
        _log.warning('[OSC] Malformed body (non-numeric command) body="$body"');
      }
      return;
    }

    final handler = _oscHandlers[code];
    if (handler != null) {
      handler(params);
    } else {
      if (controller.debugLogging) {
        _log.warning('[OSC] Unimplemented body="$body"');
      }
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

  void _escNextLine() => controller.activeBuffer.nextLine();

  void _escHorizontalTabSet() => controller.activeBuffer.horizontalTabSet();

  void _escReverseIndex() => controller.activeBuffer.reverseIndex();

  void _escSingleShift2() => controller.activeBuffer.charset.singleShift(2);

  void _escSingleShift3() => controller.activeBuffer.charset.singleShift(3);

  // --- CSI Handlers ---

  void _csiInsertBlanks(CsiParseResult parsed) => controller.activeBuffer
      .insertBlanks(_parseSingleParam(parsed, defaultValue: 1));

  void _csiCursorUp(CsiParseResult parsed) =>
      controller.activeBuffer.cursorUp(_parseSingleParam(parsed));

  void _csiCursorDown(CsiParseResult parsed) =>
      controller.activeBuffer.cursorDown(_parseSingleParam(parsed));

  void _csiLinePositionAbsolute(CsiParseResult parsed) =>
      controller.activeBuffer.setCursorPosition(
        (parsed.params.isNotEmpty ? (parsed.params[0] ?? 1) : 1) - 1,
        controller.activeBuffer.cursorCol,
      );

  void _csiEraseCharacter(CsiParseResult parsed) {
    final amount = _parseSingleParam(parsed, defaultValue: 1);
    final buf = controller.activeBuffer;
    for (
      var c = buf.cursorCol;
      c < min(buf.cursorCol + amount, controller.cols);
      c++
    ) {
      buf.eraseCell(buf.cursorRow, c);
    }
  }

  void _csiCursorRight(CsiParseResult parsed) =>
      controller.activeBuffer.cursorRight(_parseSingleParam(parsed));

  void _csiCursorLeft(CsiParseResult parsed) =>
      controller.activeBuffer.cursorLeft(_parseSingleParam(parsed));

  void _csiCursorHorizontalAbsolute(CsiParseResult parsed) {
    final col = (parsed.params.isNotEmpty ? (parsed.params[0] ?? 1) : 1) - 1;
    controller.activeBuffer.setCursorPosition(
      controller.activeBuffer.cursorRow,
      col,
    );
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
        break;
      case 1:
        controller.activeBuffer.eraseDisplayAbove();
        break;
      case 2:
        controller.activeBuffer.eraseDisplayComplete();
        break;
      case 3:
        controller.activeBuffer.eraseDisplayScrollback();
        break;
      default:
        _log.warning('\tUnhandled ED mode: $mode');
        break;
    }
  }

  void _csiEraseLine(CsiParseResult parsed) {
    final mode = _parseSingleParam(parsed);
    switch (mode) {
      case 0:
        controller.activeBuffer.eraseLineRight();
        break;
      case 1:
        controller.activeBuffer.eraseLineLeft();
        break;
      case 2:
        controller.activeBuffer.eraseLineComplete();
        break;
      default:
        _log.warning('\tUnhandled EL mode: $mode');
        break;
    }
  }

  void _csiInsertLine(CsiParseResult parsed) => controller.activeBuffer
      .insertLines(_parseSingleParam(parsed, defaultValue: 1));

  void _csiDeleteLine(CsiParseResult parsed) => controller.activeBuffer
      .deleteLines(_parseSingleParam(parsed, defaultValue: 1));

  void _csiDeleteCharacter(CsiParseResult parsed) =>
      controller.activeBuffer.deleteCharacter(_parseSingleParam(parsed));

  void _csiScrollUp(CsiParseResult parsed) => controller.activeBuffer.scrollUp(
    _parseSingleParam(parsed, defaultValue: 1),
  );

  void _csiScrollDown(CsiParseResult parsed) => controller.activeBuffer
      .scrollDown(_parseSingleParam(parsed, defaultValue: 1));

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
    for (final p in parsed.params) {
      final mode = p ?? 0;

      if (isPrivate) {
        switch (mode) {
          case 1:
            controller.applicationCursorKeys = enabled;
            break;
          case 7:
            controller.setAutoWrapMode(enabled);
            break;
          case 12:
            if (enabled) {
              controller.resetCursorBlinkInterval();
            } else {
              controller.setCursorBlinkInterval(.zero);
            }
            break;
          case 25:
            controller.setCursorVisible(enabled);
            break;
          case 1000:
            controller.setMouseTrackingMode(MouseTrackingMode.normal, enabled);
            break;
          case 1002:
            controller.setMouseTrackingMode(
              MouseTrackingMode.buttonEvent,
              enabled,
            );
            break;
          case 1003:
            controller.setMouseTrackingMode(
              MouseTrackingMode.anyEvent,
              enabled,
            );
            break;
          case 1006:
            controller.sgrMouseMode = enabled;
            break;
          case 1007:
            controller.alternateScrollMode = enabled;
            break;
          case 1015:
            controller.urxvtMouseMode = enabled;
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
          case 2004:
            controller.bracketedPasteMode = enabled;
            break;
          case 2026:
            controller.setSynchronizedOutput(enabled);
            break;
          default:
            if (controller.debugLogging) {
              _log.warning(
                '\tUnhandled private mode: $mode (enabled=$enabled)',
              );
            }
        }
      } else {
        switch (mode) {
          case 4:
            controller.setInsertMode(enabled);
            break;
          case 20:
            controller.setLineFeedMode(enabled);
            break;
          default:
            if (controller.debugLogging) {
              _log.warning(
                '\tUnhandled standard mode: $mode (enabled=$enabled)',
              );
            }
        }
      }
    }
  }

  /// https://terminalguide.namepad.de/seq/csi_sm/
  void _csiSelectGraphicRendition(CsiParseResult parsed) {
    var formatting = controller.activeBuffer.currentFormat;
    final List<int> codes = parsed.params.isEmpty
        ? const <int>[0]
        : parsed.params.map((p) => p ?? 0).toList(growable: false);
    int offset = 0;
    while (offset < codes.length) {
      int code = codes[offset++];
      formatting = (switch (code) {
        0 => () => FormattingOptions.defaultFormat,
        1 => () => formatting.copyWith(bold: true),
        2 => () => formatting.copyWith(faint: true),
        3 => () => formatting.copyWith(italic: true),
        4 => () => formatting.copyWith(underline: Underline.single),
        7 => () => formatting.copyWith(inverted: true),
        8 => () => formatting.copyWith(concealed: true),
        21 => () => formatting.copyWith(underline: Underline.double),
        22 => () => formatting.copyWith(bold: false, faint: false),
        23 => () => formatting.copyWith(italic: false),
        24 => () => formatting.copyWith(underline: Underline.none),
        27 => () => formatting.copyWith(inverted: false),
        28 => () => formatting.copyWith(concealed: false),
        >= 30 && <= 37 => () => formatting.copyWith(
          fgColor: ansi16ToColor(controller.theme, code - 30),
        ),
        38 => () {
          if (offset >= codes.length) return formatting;
          switch (codes[offset++]) {
            case 5:
              if (offset >= codes.length) return formatting;
              return formatting.copyWith(
                fgColor: xterm256ToColor(controller.theme, codes[offset++]),
              );
            case 2:
              if (offset + 2 >= codes.length) return formatting;
              final res = formatting.copyWith(
                fgColor: rgbToColor(
                  codes[offset],
                  codes[offset + 1],
                  codes[offset + 2],
                ),
              );
              offset += 3;
              return res;
            default:
              return formatting;
          }
        },
        39 => () => formatting.copyWith(fgColor: null),
        >= 40 && <= 47 => () => formatting.copyWith(
          bgColor: ansi16ToColor(controller.theme, code - 40),
        ),
        48 => () {
          if (offset >= codes.length) return formatting;
          switch (codes[offset++]) {
            case 5:
              if (offset >= codes.length) return formatting;
              return formatting.copyWith(
                bgColor: xterm256ToColor(controller.theme, codes[offset++]),
              );
            case 2:
              if (offset + 2 >= codes.length) return formatting;
              final res = formatting.copyWith(
                bgColor: rgbToColor(
                  codes[offset],
                  codes[offset + 1],
                  codes[offset + 2],
                ),
              );
              offset += 3;
              return res;
            default:
              return formatting;
          }
        },
        49 => () => formatting.copyWith(bgColor: null),
        >= 90 && <= 97 => () => formatting.copyWith(
          fgColor: ansi16ToColor(controller.theme, (code - 90) + 8),
        ),
        >= 100 && <= 107 => () => formatting.copyWith(
          bgColor: ansi16ToColor(controller.theme, (code - 100) + 8),
        ),
        _ => () => formatting,
      }).call();
    }
    controller.activeBuffer.currentFormat = formatting;
  }

  void _csiSelectCursorStyle(CsiParseResult parsed) {
    if (parsed.intermediates != ' ') {
      if (controller.debugLogging) {
        _log.warning(
          '\tUnhandled CSI q variant: intermediates="${parsed.intermediates}"',
        );
      }
      return;
    }

    final mode = _parseSingleParam(parsed, defaultValue: 1);
    switch (mode) {
      case 0:
      case 1:
      case 2:
        controller.setCursorStyle(.block);
        break;
      case 3:
      case 4:
        controller.setCursorStyle(.underline);
        break;
      case 5:
      case 6:
        controller.setCursorStyle(.bar);
        break;
      default:
        if (controller.debugLogging) {
          _log.warning('\tUnhandled DECSCUSR mode: $mode');
        }
    }
    // mode 1, 3 and 5 are the blinking variants of the cursor styles.
    // mode 0 simply defaults to blinking block.
    if (mode == 0 || mode % 2 != 0) {
      controller.resetCursorBlinkInterval();
    } else {
      // while mode 2, 4 and 6 are the steady variants.
      controller.setCursorBlinkInterval(.zero);
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

  /// Window Manipulation (XTWINOPS)
  /// - https://terminalguide.namepad.de/seq/csi_st-14/
  /// - https://terminalguide.namepad.de/seq/csi_st-22/
  /// - https://terminalguide.namepad.de/seq/csi_st-23/
  void _csiWindowManipulation(CsiParseResult parsed) {
    if (parsed.params.isEmpty) return;
    final ps = parsed.params[0] ?? 0;
    final ps2 = parsed.params.length >= 2 ? (parsed.params[1] ?? 0) : 0;

    switch (ps) {
      case 14:
        controller.emit(
          EscapeEmitter.sizeInPixels(
            controller.height.round(),
            controller.width.round(),
          ),
        );
        break;
      case 18:
        controller.emit(EscapeEmitter.size(controller.rows, controller.cols));
        break;
      case 22:
        controller.pushWindowTitle(ps2);
        break;
      case 23:
        controller.popWindowTitle(ps2);
        break;
      default:
        if (controller.debugLogging) {
          _log.warning('\tUnhandled window manipulation Ps: $ps');
        }
        break;
    }
  }

  // --- OSC Handlers ---

  void _oscSetWindowTitle(String params) => controller.setWindowTitle(params);
}
