import 'dart:convert';
import 'dart:ui';

import 'package:cliq/modules/settings/model/terminal_theme_parser/terminal_theme_parser.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/extensions/color.extension.dart';
import 'package:drift/drift.dart';
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

  const KittyTerminalThemeParser();

  @override
  bool canParse(String content) {
    final lines = _getEffectiveLines(content);
    if (lines.isEmpty) {
      return false;
    }
    for (final line in lines) {
      // check if line starts with any of the fields
      for (final field in fields) {
        if (line.trim().startsWith('$field #')) {
          return true;
        }
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
          final colorValue = line.trim().substring(field.length).trim();
          colorMap[field] = ColorExtension.fromHex(colorValue)!;
        }
      }
    }

    if (colorMap.isEmpty || colorMap.length != fields.length) {
      logger.warning('Failed to parse theme $fileName: Expected ${fields.length} fields, got ${colorMap.length}');
      return null;
    }

    // kitty themes don't have a name field, so we can use the file name as the theme name
    final themeName = fileName.split('.').first;

    try {
      return CustomTerminalThemesCompanion.insert(
        name: themeName,
        blackColor: colorMap['color0']!,
        redColor: colorMap['color1']!,
        greenColor: colorMap['color2']!,
        yellowColor: colorMap['color3']!,
        blueColor: colorMap['color4']!,
        purpleColor: colorMap['color5']!,
        cyanColor: colorMap['color6']!,
        whiteColor: colorMap['color7']!,
        brightBlackColor: colorMap['color8']!,
        brightRedColor: colorMap['color9']!,
        brightGreenColor: colorMap['color10']!,
        brightYellowColor: colorMap['color11']!,
        brightBlueColor: colorMap['color12']!,
        brightPurpleColor: colorMap['color13']!,
        brightCyanColor: colorMap['color14']!,
        brightWhiteColor: colorMap['color15']!,
        backgroundColor: colorMap['background']!,
        foregroundColor: colorMap['foreground']!,
        cursorColor: colorMap['cursor']!,
        selectionBackgroundColor: colorMap['selection_background']!,
        selectionForegroundColor: Value(colorMap['selection_foreground']!),
        cursorTextColor: Value(colorMap['cursor_text_color']),
      );
    } catch (e) {
      logger.warning('Failed to parse theme $fileName: $e');
      return null;
    }
  }

  List<String> _getEffectiveLines(String content) {
    final lines = LineSplitter.split(content);
    return lines.where((line) => line.trim().isNotEmpty && !line.trim().startsWith('#')).toList();
  }
}
