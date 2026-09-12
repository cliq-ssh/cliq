import 'dart:ui';

import 'package:cliq/modules/settings/data/custom_terminal_themes.repository.dart';
import 'package:cliq/shared/data/database.dart';

import 'package:cliq/shared/extensions/value.extension.dart';

final class CustomTerminalThemeService {
  final CustomTerminalThemesRepository _customTerminalThemesRepository;

  const new(this._customTerminalThemesRepository);

  Stream<List<CustomTerminalTheme>> watchAll() {
    return _customTerminalThemesRepository.selectAll().watch();
  }

  Future<DbId> createCustomTerminalTheme(
    CustomTerminalThemesCompanion insert,
  ) async {
    return (await _customTerminalThemesRepository.insert(insert)).id;
  }

  Future<DbId> update(
    DbId themeId, {
    required String? name,
    required Color? black,
    required Color? red,
    required Color? green,
    required Color? yellow,
    required Color? blue,
    required Color? purple,
    required Color? cyan,
    required Color? white,
    required Color? brightBlack,
    required Color? brightRed,
    required Color? brightGreen,
    required Color? brightYellow,
    required Color? brightBlue,
    required Color? brightPurple,
    required Color? brightCyan,
    required Color? brightWhite,
    required Color? background,
    required Color? foreground,
    required Color? cursor,
    required Color? cursorText,
    required Color? selectionBackground,
    required Color? selectionForeground,
    CustomTerminalThemesCompanion? compareTo,
  }) async {
    await _customTerminalThemesRepository.updateById(
      themeId,
      CustomTerminalThemesCompanion(
        name: ValueExtension.absentIfNullOrSame(name, compareTo?.name),
        black: ValueExtension.absentIfNullOrSame(black, compareTo?.black),
        red: ValueExtension.absentIfNullOrSame(red, compareTo?.red),
        green: ValueExtension.absentIfNullOrSame(green, compareTo?.green),
        yellow: ValueExtension.absentIfNullOrSame(yellow, compareTo?.yellow),
        blue: ValueExtension.absentIfNullOrSame(blue, compareTo?.blue),
        purple: ValueExtension.absentIfNullOrSame(purple, compareTo?.purple),
        cyan: ValueExtension.absentIfNullOrSame(cyan, compareTo?.cyan),
        white: ValueExtension.absentIfNullOrSame(white, compareTo?.white),
        brightBlack: ValueExtension.absentIfNullOrSame(
          brightBlack,
          compareTo?.brightBlack,
        ),
        brightRed: ValueExtension.absentIfNullOrSame(
          brightRed,
          compareTo?.brightRed,
        ),
        brightGreen: ValueExtension.absentIfNullOrSame(
          brightGreen,
          compareTo?.brightGreen,
        ),
        brightYellow: ValueExtension.absentIfNullOrSame(
          brightYellow,
          compareTo?.brightYellow,
        ),
        brightBlue: ValueExtension.absentIfNullOrSame(
          brightBlue,
          compareTo?.brightBlue,
        ),
        brightPurple: ValueExtension.absentIfNullOrSame(
          brightPurple,
          compareTo?.brightPurple,
        ),
        brightCyan: ValueExtension.absentIfNullOrSame(
          brightCyan,
          compareTo?.brightCyan,
        ),
        brightWhite: ValueExtension.absentIfNullOrSame(
          brightWhite,
          compareTo?.brightWhite,
        ),
        background: ValueExtension.absentIfNullOrSame(
          background,
          compareTo?.background,
        ),
        foreground: ValueExtension.absentIfNullOrSame(
          foreground,
          compareTo?.foreground,
        ),
        cursor: ValueExtension.absentIfNullOrSame(cursor, compareTo?.cursor),
        cursorText: ValueExtension.absentIfNullOrSame(
          cursorText,
          compareTo?.cursorText,
        ),
        selectionBackground: ValueExtension.absentIfNullOrSame(
          selectionBackground,
          compareTo?.selectionBackground,
        ),
        selectionForeground: ValueExtension.absentIfNullOrSame(
          selectionForeground,
          compareTo?.selectionForeground,
        ),
      ),
    );
    return themeId;
  }

  Future<List<CustomTerminalTheme>> findByIds(List<DbId> ids) {
    return _customTerminalThemesRepository.db
        .findAllCustomColorSchemesByIds(ids)
        .get();
  }

  /// Returns the id of an existing theme whose values match [colorScheme] exactly, or null if no such theme exists.
  Future<DbId?> findIdOfMatchingTheme(
    CustomTerminalThemesCompanion colorScheme,
  ) {
    return _customTerminalThemesRepository.db
        .findMatchingCustomColorSchemeId(
          colorScheme.name.value,
          colorScheme.black.value,
          colorScheme.red.value,
          colorScheme.green.value,
          colorScheme.yellow.value,
          colorScheme.blue.value,
          colorScheme.purple.value,
          colorScheme.cyan.value,
          colorScheme.white.value,
          colorScheme.brightBlack.value,
          colorScheme.brightRed.value,
          colorScheme.brightGreen.value,
          colorScheme.brightYellow.value,
          colorScheme.brightBlue.value,
          colorScheme.brightPurple.value,
          colorScheme.brightCyan.value,
          colorScheme.brightWhite.value,
          colorScheme.background.value,
          colorScheme.foreground.value,
          colorScheme.cursor.value,
          colorScheme.cursorText.value,
          colorScheme.selectionBackground.value,
          colorScheme.selectionForeground.value,
        )
        .getSingleOrNull();
  }

  /// Convenience method to check if a theme with the same values as [colorScheme] already exists in the database.
  /// See [findIdOfMatchingTheme] for more details.
  Future<bool> doesExist({
    required CustomTerminalThemesCompanion colorScheme,
  }) async {
    return (await findIdOfMatchingTheme(colorScheme)) != null;
  }

  Future<int> createOrUpdate({
    required DbId id,
    required String name,
    required Color black,
    required Color red,
    required Color green,
    required Color yellow,
    required Color blue,
    required Color purple,
    required Color cyan,
    required Color white,
    required Color brightBlack,
    required Color brightRed,
    required Color brightGreen,
    required Color brightYellow,
    required Color brightBlue,
    required Color brightPurple,
    required Color brightCyan,
    required Color brightWhite,
    required Color background,
    required Color foreground,
    required Color cursor,
    required Color cursorText,
    required Color selectionBackground,
    required Color selectionForeground,
  }) async {
    final result = await _customTerminalThemesRepository.db
        .createOrUpdateCustomColorScheme(
          id,
          name,
          black,
          red,
          green,
          yellow,
          blue,
          purple,
          cyan,
          white,
          brightBlack,
          brightRed,
          brightGreen,
          brightYellow,
          brightBlue,
          brightPurple,
          brightCyan,
          brightWhite,
          background,
          foreground,
          cursor,
          cursorText,
          selectionBackground,
          selectionForeground,
        );

    return result;
  }

  Future<void> deleteById(DbId id) =>
      _customTerminalThemesRepository.deleteById(id);
}
