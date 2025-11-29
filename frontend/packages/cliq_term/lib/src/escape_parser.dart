import 'package:cliq_term/src/model/color.dart';

import './model/formatting_options.dart';

enum States { initial, openBracket }

typedef _ArgParserReturn = (int offset, String arg);

const numberChars = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"];

_ArgParserReturn _parseInt(String input, int baseOffset) {
  int offset = 0;
  String arg = "";

  String curChar = input[baseOffset + offset];
  while (numberChars.contains(curChar)) {
    arg += curChar;
    curChar = input[baseOffset + (++offset)];
  }

  return (offset, arg);
}

void _setFormattingFromArgs(List<String> args, FormattingOptions formatting) {
  /*
  Code     Effect                                      Note

  0        Reset / Normal                              all attributes off
  1        Bold or increased intensity
  2        Faint (decreased intensity)                 Not widely supported.
  3        Italic                                      Not widely supported. Sometimes treated as inverse.
  4        Underline
  5        Slow Blink                                  less than 150 per minute
  6        Rapid Blink                                 MS-DOS ANSI.SYS; 150+ per minute; not widely supported
  7        [[reverse video]]                           swap foreground and background colors
  8        Conceal                                     Not widely supported.
  9        Crossed-out                                 Characters legible, but marked for deletion. Not widely supported.
  10       Primary(default) font
  11–19    Alternate font                              Select alternate font n-10
  20       Fraktur                                     hardly ever supported
  21       Bold off or Double Underline                Bold off not widely supported; double underline hardly ever supported.
  22       Normal color or intensity                   Neither bold nor faint
  23       Not italic, not Fraktur
  24       Underline off                               Not singly or doubly underlined
  25       Blink off
  27       Inverse off
  28       Reveal                                      conceal off
  29       Not crossed out

  30–37    Set foreground color                        See color table below
  38       Set foreground color                        Next arguments are 5;<n> or 2;<r>;<g>;<b>, see below
  39       Default foreground color                    implementation defined (according to standard)

  40–47    Set background color                        See color table below
  48       Set background color                        Next arguments are 5;<n> or 2;<r>;<g>;<b>, see below
  49       Default background color                    implementation defined (according to standard)

  51       Framed
  52       Encircled
  53       Overlined
  54       Not framed or encircled
  55       Not overlined

  60       ideogram underline                          hardly ever supported
  61       ideogram double underline                   hardly ever supported
  62       ideogram overline                           hardly ever supported
  63       ideogram double overline                    hardly ever supported
  64       ideogram stress marking                     hardly ever supported
  65       ideogram attributes off                     reset the effects of all of 60-64

  2J => clear by commiting the whole active screen to the backbuffer (including empty lines)

  */

  List<int> codes = args.map(int.parse).toList(growable: false);
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
        formatting.fgColor.type = ColorType.ansi16;
        formatting.fgColor.code = code - 30;
        break;
      case 38:
        // 38       Set foreground color                        Next arguments are 5;<n> or 2;<r>;<g>;<b>, see below
        if (offset == codes.length) break;
        switch (codes[offset++]) {
          case 5:
            if (offset == codes.length) break;
            formatting.fgColor.type = ColorType.xterm256;
            formatting.fgColor.code = codes[offset];
            break;
          case 2:
            if ((offset + 2) == codes.length) break;
            formatting.fgColor.type = ColorType.rgb;
            formatting.fgColor.code =
                ((codes[offset++] & 0xff) << 16) &
                ((codes[offset++] & 0xff) << 8) &
                (codes[offset++] & 0xff);
          default:
            break;
        }
        break;
      case 39:
        formatting.fgColor.type = ColorType.defaultColor;
        formatting.fgColor.code = 0;
        break;
      case >= 40 && <= 47:
        formatting.bgColor.type = ColorType.ansi16;
        formatting.bgColor.code = code - 40;
        break;
      case 48:
        if (offset == codes.length) break;
        switch (codes[offset]) {
          case 5:
            if ((offset + 1) == codes.length) break;
            formatting.bgColor.type = ColorType.xterm256;
            formatting.bgColor.code = codes[offset + 1];
            break;
          case 2:
            if ((offset + 3) == codes.length) break;
            formatting.bgColor.type = ColorType.rgb;
            formatting.bgColor.code =
                ((codes[offset + 1] & 0xff) << 16) &
                ((codes[offset + 2] & 0xff) << 8) &
                (codes[offset + 3] & 0xff);
          default:
            break;
        }
        break;
      case 49:
        formatting.bgColor.type = ColorType.defaultColor;
        formatting.bgColor.code = 1;
      default:
        // NYI / ignored
        break;
    }
  }
}

void commitToBackBuffer() {
  // TermBuffer cur_view, Buff back_buffer
}

class EscapeParser {
  static int parse(
    String input,
    int initialOffset,
    FormattingOptions formatting,
  ) {
    int offset = initialOffset;
    bool running = true;
    List<String> args = [];
    States state = States.initial;

    while (running) {
      String curChar = input[offset];

      switch (state) {
        case States.initial:
          switch (curChar) {
            case '[':
              state = States.openBracket;
              offset++;
              continue;
          }
          break;
        case States.openBracket:
          bool parsingArgs = true;
          while (parsingArgs) {
            var (parsedOffset, parsedArg) = _parseInt(input, offset);
            if (parsedOffset > 0) {
              offset += parsedOffset;
              args.add(parsedArg);
              switch (input[offset++]) {
                case "J":
                  if (args.length == 1 && args[0] == "2") commitToBackBuffer();
                case ";":
                  continue;
                case "m":
                  _setFormattingFromArgs(args, formatting);
                  args = [];
                  break;
              }
            } else {
              parsingArgs = false;
              args = [];
            }
          }
          break;
      }
    }
  }
}
