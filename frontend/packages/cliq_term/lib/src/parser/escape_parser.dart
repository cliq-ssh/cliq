import 'package:cliq_term/cliq_term.dart';
import 'package:logging/logging.dart';

import '../model/color.dart';

typedef CsiHandler = void Function(
  List<int?> params,
  String? leader,
  String intermediates,
  int finalByteCode,
);

class EscapeParser {
  static final Logger _log = Logger('EscapeParser');

  final TerminalController controller;
  final TerminalColorTheme colors;

  late final Map<String, void Function()> _codes = {
    'BEL': _ccBell,
    // 'BS': _ccBackspace,
    // 'HT': _ccHorizontalTab,
    // 'LF': _ccLineFeed,
    // 'VT': _ccVerticalTab,
    // 'FF': _ccFormFeed,
    // 'CR': _ccCarriageReturn,
    // 'SO': _ccShiftOut,
    // 'SI': _ccShiftIn,
    // 'CAN': _ccCancelParsingCAN,
    // 'SUB': _ccCancelParsingSUB,

    // -- Escape Sequences --
    // 'ESC 6': _escBackIndex,
    // 'ESC 7': _escSaveCursor,
    // 'ESC 8': _escRestoreCursor,
    // 'ESC 9': _escForwardIndex,
    // 'ESC D': _escIndex,
    // 'ESC E': _escNextLine,
    // 'ESC H': _escTabSet,
    // 'ESC M': _escReverseIndex,
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

  late final Map<String, void Function()> _csiCodes = {
    // 'A': _csiCursorUp,
    //
  };

  EscapeParser({
    required this.controller,
    required this.colors,
  });

  @Deprecated('Goal is to remove this method ;)')
  void __unimplementedSeq(String seq) {
    _log.fine('Unimplemented escape sequence: $seq');
  }

  // ---- Control Character Handlers ---

  /// https://terminalguide.namepad.de/seq/a_c0-g/
  void _ccBell() {
    controller.onBell?.call();
  }

  // --- Escape Sequence Handlers ---

  void _escHandleCsi() {
    // csiBody is the characters following ESC[ up to and including the final byte
    // Example: "31;1m" or "?25h"
    final parsed = _parseCsi(csiBody);
    final handler = _csiHandlers[parsed.finalByteCode];
    if (handler != null) {
      handler(
        params: parsed.params,
        leader: parsed.leader,
        intermediates: parsed.intermediates,
        finalByteCode: parsed.finalByteCode,
      );
    } else {
      _log.fine('Unhandled CSI final=0x${parsed.finalByteCode.toRadixString(16)} body="$csiBody"');
      // optional: a fallback handler or ignore
      __unimplementedSeq('CSI $csiBody');
    }
  }








  /// Parses an ANSI escape sequence from [input] starting at [initialOffset].
  /// Applies formatting changes to [formatting] and terminal actions to [controller].
  /// Returns the number of characters consumed from [input].
  int parse(
    String input,
    int initialOffset,
    FormattingOptions formatting,
  ) {
    if (initialOffset >= input.length) return 0;
    int offset = initialOffset;
    if (input[offset] != '[') return 0;
    offset++;

    List<String> args = [];

    // SGR; set graphic rendition
    int applySGRandReturn(int after) {
      final norm = args.isEmpty
          ? <String>['0']
          : args.map((s) => s.isEmpty ? '0' : s).toList(growable: false);
      setFormattingFromArgs(norm, formatting);
      return after - initialOffset;
    }

    // J; erase screen
    int applyJandReturn(int after) {
      final first = args.isEmpty ? '' : args[0];
      final mode = first.isEmpty ? 0 : int.tryParse(first) ?? 0;
      if (mode == 2) controller.commitToBackBuffer();
      return after - initialOffset;
    }

    while (offset < input.length) {
      var (parsedOffset, parsedArg) = _parseInt(input, offset);

      if (parsedOffset > 0) {
        offset += parsedOffset;
        args.add(parsedArg);
        if (offset >= input.length) break;
        final next = input[offset++];

        if (next == ';') continue;
        if (next == 'm') return applySGRandReturn(offset);
        if (next == 'J') return applyJandReturn(offset);
        return offset - initialOffset;
      }

      final cur = input[offset];
      if (cur == ';') {
        args.add('');
        offset++;
        continue;
      }

      final cu = cur.codeUnitAt(0);
      if (cu >= 0x40 && cu <= 0x7E) {
        offset++;
        if (cur == 'm') return applySGRandReturn(offset);
        if (cur == 'J') return applyJandReturn(offset);
        return offset - initialOffset;
      }

      _log.fine(
        'Unimplemented escape sequence! Encountered ${input.substring(initialOffset, input.length)}',
      );
      offset++;
    }

    return offset - initialOffset;
  }

  /// Applies SGR (Select Graphic Rendition) parameters from [args] to [formatting].
  void setFormattingFromArgs(
    List<String> args,
    FormattingOptions formatting,
  ) {
    final codes = args
        .map((s) => s.isEmpty ? 0 : int.tryParse(s) ?? 0)
        .toList();

    int offset = 0;
    while (offset < codes.length) {
      int code = codes[offset++];

      switch (code) {
        case 0:
          formatting.reset();
          break;
        case 1:
          formatting.bold = true;
          break;
        case 2:
          formatting.faint = true;
          break;
        case 3:
          formatting.italic = true;
          break;
        case 4:
          formatting.underline = Underline.single;
          break;
        case 8:
          formatting.concealed = true;
          break;
        case 21:
          formatting.underline = Underline.double;
          break;
        case 22:
          formatting.bold = false;
          formatting.faint = false;
          break;
        case 23:
          formatting.italic = false;
          break;
        case 24:
          formatting.underline = Underline.none;
          break;
        case 28:
          formatting.concealed = false;
          break;
        case >= 30 && <= 37:
          formatting.fgColor = ansi8ToColor(controller.colors, code - 30);
          break;
        case 38:
          // 38       Set foreground color                        Next arguments are 5;<n> or 2;<r>;<g>;<b>, see below
          if (offset == codes.length) break;
          switch (codes[offset++]) {
            case 5:
              if (offset == codes.length) break;
              formatting.fgColor = xterm256ToColor(
                controller.colors,
                codes[offset],
              );
              break;
            case 2:
              if ((offset + 2) == codes.length) break;
              formatting.fgColor = rgbToColor(
                codes[offset - 3],
                codes[offset - 2],
                codes[offset - 1],
              );
            default:
              break;
          }
          break;
        case 39:
          formatting.fgColor = null;
          break;
        case >= 40 && <= 47:
          formatting.bgColor = ansi8ToColor(controller.colors, code - 40);
          break;
        case 48:
          if (offset == codes.length) break;
          switch (codes[offset]) {
            case 5:
              if ((offset + 1) == codes.length) break;
              formatting.bgColor = xterm256ToColor(
                controller.colors,
                codes[offset + 1],
              );
              break;
            case 2:
              if ((offset + 3) == codes.length) break;
              formatting.bgColor = rgbToColor(
                codes[offset + 1],
                codes[offset + 2],
                codes[offset + 3],
              );
            default:
              break;
          }
          break;
        case 49:
          formatting.bgColor = null;
        default:
          // NYI / ignored
          break;
      }
    }
  }

  static (int, String) _parseInt(String input, int offset) {
    int start = offset;
    while (offset < input.length && _isDigit(input[offset])) {
      offset++;
    }
    if (offset > start) {
      return (offset - start, input.substring(start, offset));
    }
    return (0, '');
  }

  static bool _isDigit(String ch) {
    final cu = ch.codeUnitAt(0);
    return cu >= 0x30 && cu <= 0x39;
  }
}

extension StringExtension on String {
  int get c => codeUnitAt(0);
}
