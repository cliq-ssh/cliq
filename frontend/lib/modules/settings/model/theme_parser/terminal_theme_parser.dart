import 'package:cliq/modules/settings/model/theme_parser/kitty_terminal_theme_parser.dart';
import 'package:cliq/modules/settings/model/theme_parser/windows_terminal_theme_parser.dart';
import 'package:cliq/shared/data/database.dart';

enum TerminalThemeParser {
  windowsTerminal(WindowsTerminalThemeParser(), 'json'),
  kitty(KittyTerminalThemeParser(), 'conf');

  final String fileExtension;
  final AbstractTerminalThemeParser instance;

  new(this.instance, this.fileExtension);

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
  const new();

  bool canParse(String content);
  CustomTerminalThemesCompanion? tryParse(String fileName, String content);
}
