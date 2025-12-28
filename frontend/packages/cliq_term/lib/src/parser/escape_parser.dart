import 'package:cliq_term/cliq_term.dart';
import 'package:cliq_term/src/parser/csi_parser.dart';
import 'package:logging/logging.dart';

import '../rendering/model/color.dart';
import '../rendering/model/esc_terminator.dart';

typedef EscHandler = void Function(String body, FormattingOptions formatting);

typedef CsiHandler =
    void Function(CsiParseResult parsed, FormattingOptions formatting);

class EscapeParser {
  static final Logger _log = Logger('EscapeParser');

  final TerminalController controller;
  final TerminalColorTheme colors;

  late final CsiParser _csiParser = CsiParser();

  final Map<String, EscTerminator> _escTerminators = {
    'ESC [': .csi,
    'ESC ]': .osc,
    'ESC P': .escBackslash,
  };

  late final Map<String, EscHandler> _escHandlers = {
    // 'ESC 6': _escBackIndex,
    'ESC 7': _escSaveCursor,
    'ESC 8': _escRestoreCursor,
    // 'ESC 9': _escForwardIndex,
    'ESC D': _escIndex,
    // 'ESC E': _escNextLine,
    // 'ESC H': _escTabSet,
    'ESC M': _escReverseIndex,
    // 'ESC N': _escSingleShift2,
    // 'ESC O': _escSingleShift3,
    // 'ESC V': _escStartProtectedArea,
    // 'ESC W': _escEndProtectedArea,
    // 'ESC Z': _escReturnTerminalId,
    // 'ESC c': _escFullReset,
    // 'ESC l': _escHPMemoryLock,
    // 'ESC m': _escHPMemoryUnlock,
    // 'ESC n': _escLockingShift2,
    // 'ESC o': _escLockingShift3,
    // 'ESC >': _escResetApplicationKeypadMode,
    // 'ESC =': _escSetApplicationKeypadMode,
    // 'ESC |': _escLockingShift3R,
    // 'ESC }': _escLockingShift2R,
    // 'ESC ~': _escLockingShift1R,
    // 'ESC #': ???
    'ESC [': _escHandleCsi,
  };

  /// Map of CSI final byte codes to their handlers.
  late final Map<int, CsiHandler> _csiHandlers = {
    'A'.codeUnitAt(0): _csiCursorUpOrScrollRight,
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
    // 'X'.codeUnitAt(0): _csiEraseCharacter,
    // 'Z'.codeUnitAt(0): _csiCursorHorizontalBackwardTab,
    // 'a'.codeUnitAt(0): _csiCursorHorizontalRelative,
    // 'b'.codeUnitAt(0): _csiRepeatPrevCharacter,
    // 'c'.codeUnitAt(0): _csiDeviceAttributes,
    // 'd'.codeUnitAt(0): _csiCursorVerticalPositionAbsolute,
    // 'e'.codeUnitAt(0): _csiVerticalPosRelative,
    // 'f'.codeUnitAt(0): _csiSetCursorPosition,
    // 'g'.codeUnitAt(0): _csiTabClear,
    'h'.codeUnitAt(0): _csiSetMode,
    // 'i'.codeUnitAt(0): _csiMediaControl,
    'l'.codeUnitAt(0): _csiResetMode,
    'm'.codeUnitAt(0): _csiSelectGraphicRendition,
    // 'n'.codeUnitAt(0): _csiRequestReport,
    // 'p'.codeUnitAt(0): _csiRequestMode,
    // 'q'.codeUnitAt(0): _csiSelectCursorStyle,
    'r'.codeUnitAt(0): _csiSetScrollingRegion,
    // 's'.codeUnitAt(0): _csiSaveCursor,
    // 't'.codeUnitAt(0): _csiWindowManipulation,
    // 'u'.codeUnitAt(0): _csiRestoreCursor,
  };

  EscapeParser({required this.controller, required this.colors});

  /// Parses an escape sequence starting at [initialOffset] in [input].
  /// Returns the number of characters consumed.
  ///
  /// [formatting] is the current formatting options to be modified by the escape sequence (e.g., SGR codes).
  int parse(String input, int initialOffset, FormattingOptions formatting) {
    if (initialOffset >= input.length) return 0;

    int offset = initialOffset;
    if (input.codeUnitAt(offset) == EscTerminator.escCode) {
      offset++;
      if (offset >= input.length) return 1;
    }

    final next = input[offset];
    final key = 'ESC $next';

    final term = _escTerminators[key] ?? EscTerminator.singleChar;

    /// Invoke the handler for [escKey] with [body].
    void invokeHandler(String escKey, String body) {
      final handler = _escHandlers[escKey];
      if (handler != null) {
        try {
          if (controller.debugLogging) {
            _log.finest(
              '[${term.name.toUpperCase()}] Handling $escKey body="$body"',
            );
          }
          handler(body, formatting);
        } catch (e, st) {
          _log.severe('Error handling $escKey body="$body": $e\n$st');
        }
      } else {
        if (controller.debugLogging) {
          _log.warning(
            '[${term.name.toUpperCase()}] Unimplemented $escKey body="$body"',
          );
        }
      }
    }

    switch (term) {
      case .csi:
        final start = offset;
        int i = offset + 1;
        while (i < input.length) {
          final cu = input.codeUnitAt(i);
          if (cu >= 0x40 && cu <= 0x7E) {
            final body = input.substring(start, i + 1);
            invokeHandler(key, body);
            return (i + 1) - initialOffset;
          }
          i++;
        }
        // incomplete, invoke with rest
        invokeHandler(key, input.substring(start));
        return input.length - initialOffset;

      case .escBackslash:
      case .osc:
        final start = offset;
        int i = offset + 1;
        while (i < input.length) {
          final cu = input.codeUnitAt(i);

          // only osc sequences support BEL termination
          if (term == .osc && cu == EscTerminator.belCode) {
            final body = input.substring(start, i + 1);
            invokeHandler(key, body);
            return (i + 1) - initialOffset;
          }

          // escBackslash termination
          if (cu == EscTerminator.escCode &&
              (i + 1) < input.length &&
              input.codeUnitAt(i + 1) == EscTerminator.backslashCode) {
            final body = input.substring(start, i + 2);
            invokeHandler(key, body);
            return (i + 2) - initialOffset;
          }
          i++;
        }
        invokeHandler(key, input.substring(start));
        return input.length - initialOffset;

      case .singleChar:
        invokeHandler(key, next);
        return (offset + 1) - initialOffset;
    }
  }

  int _parseSingleParam(CsiParseResult parsed) {
    return parsed.params.isNotEmpty ? (parsed.params[0] ?? 0) : 0;
  }

  // --- Escape Sequence Handlers ---

  void _escSaveCursor(String body, FormattingOptions formatting) {
    controller.activeBuffer.saveCursor();
  }

  void _escRestoreCursor(String body, FormattingOptions formatting) {
    controller.activeBuffer.restoreCursor();
  }

  void _escIndex(String body, FormattingOptions formatting) {
    controller.activeBuffer.index();
  }

  void _escReverseIndex(String body, FormattingOptions formatting) {
    controller.activeBuffer.reverseIndex();
  }

  void _escHandleCsi(String body, FormattingOptions formatting) {
    final parsed = _csiParser.parseCsi(body);

    final handler = _csiHandlers[parsed.finalByteCode];
    if (handler != null) {
      handler(parsed, formatting);
    } else {
      if (controller.debugLogging) {
        _log.warning(
          '\tUnimplemented CSI final=0x${parsed.finalByteCode.toRadixString(16)} (${String.fromCharCode(parsed.finalByteCode)}) body="$body"',
        );
      }
    }
  }

  // --- CSI Handlers ---

  void _csiCursorUpOrScrollRight(
    CsiParseResult parsed,
    FormattingOptions formatting,
  ) {
    final amount = _parseSingleParam(parsed);
    controller.activeBuffer.cursorUp(amount);
  }

  void _csiCursorDown(CsiParseResult parsed, FormattingOptions formatting) {
    final amount = _parseSingleParam(parsed);
    controller.activeBuffer.cursorDown(amount);
  }

  void _csiCursorRight(CsiParseResult parsed, FormattingOptions formatting) {
    final amount = _parseSingleParam(parsed);
    controller.activeBuffer.cursorRight(amount);
  }

  void _csiCursorLeft(CsiParseResult parsed, FormattingOptions formatting) {
    final amount = _parseSingleParam(parsed);
    controller.activeBuffer.cursorLeft(amount);
  }

  void _csiSetCursorPosition(
    CsiParseResult parsed,
    FormattingOptions formatting,
  ) {
    final row = (parsed.params.isNotEmpty ? (parsed.params[0] ?? 1) : 1) - 1;
    final col = (parsed.params.length >= 2 ? (parsed.params[1] ?? 1) : 1) - 1;
    controller.activeBuffer.setCursorPosition(row, col);
  }

  void _csiEraseDisplay(CsiParseResult parsed, FormattingOptions formatting) {
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

  void _csiEraseLine(CsiParseResult parsed, FormattingOptions formatting) {
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

  void _csiDeleteCharacter(
    CsiParseResult parsed,
    FormattingOptions formatting,
  ) {
    final amount = _parseSingleParam(parsed);
    controller.activeBuffer.deleteCharacter(amount);
  }

  /// Set Mode (SM)
  /// - https://terminalguide.namepad.de/seq/csi_sh/
  void _csiSetMode(CsiParseResult parsed, FormattingOptions formatting) {
    // TODO: handle non-DEC private modes
    if (parsed.leader != '?') return;

    for (final p in parsed.params) {
      final mode = p ?? 0;
      switch (mode) {
        case 1047:
        case 47:
          controller.useBackBuffer(saveMainAndClear: false);
          break;
        case 1049:
          // enter alt screen and save main screen state
          controller.useBackBuffer(saveMainAndClear: true);
          break;
        default:
          if (controller.debugLogging) {
            _log.warning('\tUnhandled private mode set: $mode');
          }
          break;
      }
    }
  }

  /// Reset Mode (RM)
  /// - https://terminalguide.namepad.de/seq/csi_sl/
  void _csiResetMode(CsiParseResult parsed, FormattingOptions formatting) {
    // TODO: handle non-DEC private modes
    if (parsed.leader != '?') return;

    for (final p in parsed.params) {
      final mode = p ?? 0;
      switch (mode) {
        case 1047:
        case 47:
          // leave alt screen without restoring saved state
          controller.useMainBuffer(restoreMain: false);
          break;
        case 1049:
          controller.useMainBuffer(restoreMain: true);
          break;
        default:
          if (controller.debugLogging) {
            _log.warning('\tUnhandled private mode reset: $mode');
          }
          break;
      }
    }
  }

  /// https://terminalguide.namepad.de/seq/csi_sm/
  void _csiSelectGraphicRendition(
    CsiParseResult parsed,
    FormattingOptions formatting,
  ) {
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
        8 => () => formatting.concealed = true,
        21 => () => formatting.underline = Underline.double,
        22 => () {
          formatting.bold = false;
          formatting.faint = false;
        },
        23 => () => formatting.italic = false,
        24 => () => formatting.underline = Underline.none,
        28 => () => formatting.concealed = false,
        >= 30 && <= 37 => () => formatting.fgColor = ansi8ToColor(
          controller.colors,
          code - 30,
        ),
        38 => () {
          if (offset == codes.length) return;
          switch (codes[offset++]) {
            case 5:
              if (offset == codes.length) return;
              formatting.fgColor = xterm256ToColor(
                controller.colors,
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
        >= 40 && <= 47 => () => formatting.bgColor = ansi8ToColor(
          controller.colors,
          code - 40,
        ),
        48 => () {
          if (offset == codes.length) return;
          switch (codes[offset]) {
            case 5:
              if ((offset + 1) == codes.length) return;
              formatting.bgColor = xterm256ToColor(
                controller.colors,
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
        _ => throw ArgumentError('Unhandled formatting code: $code'),
      }).call();
    }
  }

  void _csiSetScrollingRegion(
    CsiParseResult parsed,
    FormattingOptions formatting,
  ) {
    final top = (parsed.params.isNotEmpty ? (parsed.params[0] ?? 1) : 1) - 1;
    final bottom =
        (parsed.params.length >= 2
            ? (parsed.params[1] ?? controller.rows)
            : controller.rows) -
        1;
    controller.activeBuffer.setVerticalMargins(top, bottom);
  }
}
