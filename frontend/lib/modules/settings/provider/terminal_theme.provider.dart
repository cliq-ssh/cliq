import 'dart:ui';

import 'package:cliq/shared/data/database.dart';
import 'package:file_selector/file_selector.dart';
import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';

import '../../../shared/provider/abstract_entity.notifier.dart';
import '../model/terminal_theme.state.dart';
import '../model/terminal_theme_parser/terminal_theme_parser.dart';

final terminalThemeProvider = NotifierProvider(CustomTerminalThemeNotifier.new);

// TODO: replace this with custom "cliq" theme or other open source terminal theme
const CustomTerminalTheme defaultTerminalColorTheme = .new(
  id: -1,
  name: 'Darcula',
  blackColor: Color(0xFF21222C),
  redColor: Color(0xFFFF5555),
  greenColor: Color(0xFF50FA7B),
  yellowColor: Color(0xFFF1FA8C),
  blueColor: Color(0xFFBD93F9),
  purpleColor: Color(0xFFFF79C6),
  cyanColor: Color(0xFF8BE9FD),
  whiteColor: Color(0xFFF8F8F2),
  brightBlackColor: Color(0xFF6272A4),
  brightRedColor: Color(0xFFFF6E6E),
  brightGreenColor: Color(0xFF69FF94),
  brightYellowColor: Color(0xFFFFFFA5),
  brightBlueColor: Color(0xFFD6ACFF),
  brightPurpleColor: Color(0xFFFF92DF),
  brightCyanColor: Color(0xFFA4FFFF),
  brightWhiteColor: Color(0xFFFFFFFF),
  foregroundColor: Color(0xFFF8F8F2),
  cursorColor: Color(0xFFF8F8F2),
  selectionBackgroundColor: Color(0xFF44475A),
  backgroundColor: Color(0xFF282A36),
);

class CustomTerminalThemeNotifier
    extends
        AbstractEntityNotifier<CustomTerminalTheme, CustomTerminalThemeState> {
  static final logger = Logger('CustomTerminalThemeNotifier');

  /// Attempts to import the given [file] as a [CustomTerminalTheme]
  /// If the file is null, not parsable, or fails to import for any reason, this method returns null.
  /// Else, it returns the ID of the newly created theme in the database.
  Future<int?> tryImportCustomTerminalTheme(XFile? file) async {
    if (file == null) {
      return null;
    }
    final content = await file.readAsString();
    final parser = TerminalThemeParser.getParser(file.name, content);
    if (parser == null) {
      return null;
    }
    final theme = parser.tryParse(file.name, content);
    if (theme == null) {
      return null;
    }
    final id = await CliqDatabase.customTerminalThemeService.createCustomTerminalTheme(theme);
    logger.info('Successfully imported terminal theme ${theme.name} from file ${file.name} with id $id');
    return id;
  }

  @override
  CustomTerminalThemeState buildInitialState() => .initial();
  @override
  Stream<List<CustomTerminalTheme>> get entityStream =>
      CliqDatabase.customTerminalThemeService.watchAll();

  @override
  CustomTerminalThemeState buildStateFromEntities(
    List<CustomTerminalTheme> entities,
  ) => state.copyWith(entities: entities);
}
