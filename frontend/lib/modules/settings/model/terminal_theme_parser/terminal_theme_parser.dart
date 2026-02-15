import '../../../../shared/data/database.dart';
import 'kitty_terminal_theme_parser.dart';
import 'windows_terminal_theme_parser.dart';

enum TerminalThemeParser {
  windowsTerminal('json', WindowsTerminalThemeParser()),
  kitty('conf', KittyTerminalThemeParser());

  final String fileExtension;
  final AbstractTerminalThemeParser abstractParser;

  const TerminalThemeParser(this.fileExtension, this.abstractParser);

  static AbstractTerminalThemeParser? getParser(
    String fileName,
    String content,
  ) {
    final split = fileName.split('.');
    final parsers =
        split.length >
            1 // check if there is an extension
        ? TerminalThemeParser.values.where((p) => p.fileExtension == split.last)
        : TerminalThemeParser.values;

    for (final parser in parsers) {
      if (parser.abstractParser.canParse(content)) {
        return parser.abstractParser;
      }
    }
    return null;
  }
}

abstract class AbstractTerminalThemeParser {
  const AbstractTerminalThemeParser();

  bool canParse(String content);
  CustomTerminalThemesCompanion? tryParse(String fileName, String content);
}
