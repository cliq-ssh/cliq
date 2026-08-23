import 'dart:ui';

import 'package:cliq/modules/settings/model/terminal_theme.state.dart';
import 'package:cliq/modules/settings/model/theme_parser/terminal_theme_parser.dart';
import 'package:cliq/modules/settings/provider/terminal_theme_service.provider.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/model/localized_exception.dart';
import 'package:cliq/shared/provider/abstract_entity.notifier.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:logging/logging.dart';
import 'package:riverpod/riverpod.dart';

final terminalThemeProvider = NotifierProvider(CustomTerminalThemeNotifier.new);

/// Dracula
/// https://github.com/mbadolato/iTerm2-Color-Schemes/blob/0173c3cc154aab5d43b03241286d32372a87dec6/kitty/Dracula.conf
const CustomTerminalTheme defaultTerminalColorTheme = .new(
  id: '-1',
  name: 'Dracula',
  black: Color(0xFF21222C),
  red: Color(0xFFFF5555),
  green: Color(0xFF50FA7B),
  yellow: Color(0xFFF1FA8C),
  blue: Color(0xFFBD93F9),
  purple: Color(0xFFFF79C6),
  cyan: Color(0xFF8BE9FD),
  white: Color(0xFFF8F8F2),
  brightBlack: Color(0xFF6272A4),
  brightRed: Color(0xFFFF6E6E),
  brightGreen: Color(0xFF69FF94),
  brightYellow: Color(0xFFFFFFA5),
  brightBlue: Color(0xFFD6ACFF),
  brightPurple: Color(0xFFFF92DF),
  brightCyan: Color(0xFFA4FFFF),
  brightWhite: Color(0xFFFFFFFF),
  background: Color(0xFF282A36),
  foreground: Color(0xFFF8F8F2),
  cursor: Color(0xFFF8F8F2),
  cursorText: Color(0xFF282A36),
  selectionBackground: Color(0xFF44475A),
  selectionForeground: Color(0xFF282A36),
);

class CustomTerminalThemeNotifier
    extends
        AbstractEntityNotifier<CustomTerminalTheme, CustomTerminalThemeState> {
  static final logger = Logger('CustomTerminalThemeNotifier');

  /// Attempts to import the given [file] as a [CustomTerminalTheme]
  /// Throws a [LocalizedException] if the file is null, not parsable, or fails to import for any other reason.
  Future<void> tryImportCustomTerminalTheme(XFile file) async {
    final content = await file.readAsString();
    final parser = TerminalThemeParser.getParser(file.name, content);
    if (parser == null) {
      throw const LocalizedException(
        'terminal_themes_import_error.unrecognized_format',
      );
    }
    final theme = parser.tryParse(file.name, content);
    if (theme == null) {
      throw const LocalizedException(
        'terminal_themes_import_error.parsing_failed',
      );
    }

    try {
      await ref
          .read(terminalThemeServiceProvider)
          .createCustomTerminalTheme(theme);
    } catch (e) {
      logger.warning('Failed to import terminal theme (${file.name}): $e');
      throw const LocalizedException('terminal_themes_import_error.generic');
    }

    logger.info(
      'Successfully imported terminal theme ${theme.name} from file ${file.name}',
    );
  }

  @override
  CustomTerminalThemeState buildInitialState() => .initial();
  @override
  Stream<List<CustomTerminalTheme>> get entityStream =>
      ref.read(terminalThemeServiceProvider).watchAll();

  @override
  CustomTerminalThemeState buildStateFromEntities(
    List<CustomTerminalTheme> entities,
  ) => state.copyWith(entities: entities);
}
