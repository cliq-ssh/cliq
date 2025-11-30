import '../model/color.dart';
import '../model/formatting_options.dart';

class EscapeParser {
  /// Applies SGR (Select Graphic Rendition) parameters from [args] to [formatting].
  static void setFormattingFromArgs(
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
          formatting.fgColor = ansi8ToColor(code - 30);
          break;
        case 38:
          // 38       Set foreground color                        Next arguments are 5;<n> or 2;<r>;<g>;<b>, see below
          if (offset == codes.length) break;
          switch (codes[offset++]) {
            case 5:
              if (offset == codes.length) break;
              formatting.fgColor = xterm256ToColor(codes[offset]);
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
          formatting.bgColor = ansi8ToColor(code - 40);
          break;
        case 48:
          if (offset == codes.length) break;
          switch (codes[offset]) {
            case 5:
              if ((offset + 1) == codes.length) break;
              formatting.bgColor = xterm256ToColor(codes[offset + 1]);
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
}
