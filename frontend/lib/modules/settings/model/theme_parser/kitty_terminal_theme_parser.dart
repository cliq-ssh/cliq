import 'dart:convert';
import 'dart:ui';

import 'package:cliq/modules/settings/model/theme_parser/terminal_theme_parser.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/extensions/color.extension.dart';
import 'package:logging/logging.dart';

/// Parses a `.conf` Kitty Terminal Theme
///
/// The expected format is as follow:
///
/// ```conf
/// color0 #1a1a1a
/// color1 #f08898
/// color2 #a4e09c
/// color3 #f5dea4
/// color4 #84b4f8
/// color5 #c8a2f4
/// color6 #90dcd0
/// color7 #d0d6f0
/// color8 #444444
/// color9 #f08898
/// color10 #a4e09c
/// color11 #f5dea4
/// color12 #84b4f8
/// color13 #c8a2f4
/// color14 #90dcd0
/// color15 #ffffff
/// background #1a1a1a
/// selection_foreground #1a1a1a
/// cursor #f8b080
/// cursor_text_color #1a1a1a
/// foreground #d0d6f0
/// selection_background #d0d6f0
/// ```
///
/// Source: https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/kitty/Aizen%20Dark.conf
class KittyTerminalThemeParser extends AbstractTerminalThemeParser {
  static const Set<String> fields = {
    'color0',
    'color1',
    'color2',
    'color3',
    'color4',
    'color5',
    'color6',
    'color7',
    'color8',
    'color9',
    'color10',
    'color11',
    'color12',
    'color13',
    'color14',
    'color15',
    'background',
    'selection_foreground',
    'cursor',
    'cursor_text_color',
    'foreground',
    'selection_background',
  };

  static Logger logger = Logger('KittyTerminalThemeParser');

  const new();

  @override
  bool canParse(String content) {
    final lines = _getEffectiveLines(content);
    if (lines.isEmpty) {
      return false;
    }
    for (final line in lines) {
      if (!fields.any((field) => line.trim().startsWith('$field #'))) {
        return false;
      }
    }
    return true;
  }

  @override
  CustomTerminalThemesCompanion? tryParse(String fileName, String content) {
    final lines = _getEffectiveLines(content);

    final Map<String, Color> colorMap = {};
    for (final line in lines) {
      for (final field in fields) {
        if (line.trim().startsWith('$field #')) {
          final color = ColorExtension.fromHex(
            line.trim().substring(field.length).trim(),
          );
          if (color == null) {
            return null; // simply return if we fail to parse a color, we can assume the whole theme is invalid
          }
          colorMap[field] = color;
        }
      }
    }

    if (colorMap.isEmpty || colorMap.length != fields.length) {
      logger.warning(
        'Failed to parse theme $fileName: Expected ${fields.length} fields, got ${colorMap.length}',
      );
      return null;
    }

    // kitty themes don't have a name field, so we can use the file name as the theme name
    final themeName = fileName.split('.').first;

    try {
      return CustomTerminalThemesCompanion.insert(
        name: themeName,
        black: colorMap['color0']!,
        red: colorMap['color1']!,
        green: colorMap['color2']!,
        yellow: colorMap['color3']!,
        blue: colorMap['color4']!,
        purple: colorMap['color5']!,
        cyan: colorMap['color6']!,
        white: colorMap['color7']!,
        brightBlack: colorMap['color8']!,
        brightRed: colorMap['color9']!,
        brightGreen: colorMap['color10']!,
        brightYellow: colorMap['color11']!,
        brightBlue: colorMap['color12']!,
        brightPurple: colorMap['color13']!,
        brightCyan: colorMap['color14']!,
        brightWhite: colorMap['color15']!,
        background: colorMap['background']!,
        foreground: colorMap['foreground']!,
        cursor: colorMap['cursor']!,
        cursorText: colorMap['cursor_text_color']!,
        selectionForeground: colorMap['selection_foreground']!,
        selectionBackground: colorMap['selection_background']!,
      );
    } catch (e) {
      logger.warning('Failed to parse theme $fileName: $e');
      return null;
    }
  }

  List<String> _getEffectiveLines(String content) {
    final lines = LineSplitter.split(content);
    return lines
        .where((line) => line.trim().isNotEmpty && !line.trim().startsWith('#'))
        .toList();
  }
}
