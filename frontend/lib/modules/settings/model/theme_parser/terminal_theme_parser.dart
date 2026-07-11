import '../../../../shared/data/database.dart';
import 'kitty_terminal_theme_parser.dart';
import 'windows_terminal_theme_parser.dart';

enum TerminalThemeParser {
  windowsTerminal(WindowsTerminalThemeParser(), 'json', 'public.json'),
  kitty(KittyTerminalThemeParser(), 'conf', 'public.plain-text');

  final String fileExtension;
  final String uniformTypeIdentifier;
  final AbstractTerminalThemeParser instance;

  const TerminalThemeParser(this.instance, this.fileExtension, this.uniformTypeIdentifier);

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
      if (parser.instance.canParse(content)) {
        return parser.instance;
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
