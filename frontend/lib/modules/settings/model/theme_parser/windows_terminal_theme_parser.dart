import 'dart:convert';

import 'package:cliq/modules/settings/model/theme_parser/terminal_theme_parser.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/extensions/color.extension.dart';
import 'package:logging/logging.dart';

/// Parses a `.json` Windows Terminal Theme
///
/// The expected format is as follow:
///
/// ```json
/// {
///   "name": "Aizen Dark",
///   "black": "#1a1a1a",
///   "red": "#f08898",
///   "green": "#a4e09c",
///   "yellow": "#f5dea4",
///   "blue": "#84b4f8",
///   "purple": "#c8a2f4",
///   "cyan": "#90dcd0",
///   "white": "#d0d6f0",
///   "brightBlack": "#444444",
///   "brightRed": "#f08898",
///   "brightGreen": "#a4e09c",
///   "brightYellow": "#f5dea4",
///   "brightBlue": "#84b4f8",
///   "brightPurple": "#c8a2f4",
///   "brightCyan": "#90dcd0",
///   "brightWhite": "#ffffff",
///   "background": "#1a1a1a",
///   "foreground": "#d0d6f0",
///   "cursorColor": "#f8b080",
///   "selectionBackground": "#333333"
/// }
/// ```
///
/// Source: https://github.com/mbadolato/iTerm2-Color-Schemes/blob/master/windowsterminal/Aizen%20Dark.json
class WindowsTerminalThemeParser extends AbstractTerminalThemeParser {
  static const Set<String> fields = {
    'name',
    'black',
    'red',
    'green',
    'yellow',
    'blue',
    'purple',
    'cyan',
    'white',
    'brightBlack',
    'brightRed',
    'brightGreen',
    'brightYellow',
    'brightBlue',
    'brightPurple',
    'brightCyan',
    'brightWhite',
    'background',
    'foreground',
    'cursorColor',
    'selectionBackground',
  };

  static Logger logger = Logger('WindowsTerminalThemeParser');

  const new();

  @override
  bool canParse(String content) {
    try {
      final json = jsonDecode(content);
      if (json is! Map<String, dynamic>) {
        return false;
      }
      return fields.every((field) => json.containsKey(field));
    } catch (e) {
      return false;
    }
  }

  @override
  CustomTerminalThemesCompanion? tryParse(String fileName, String content) {
    try {
      final json = jsonDecode(content);
      if (json is! Map<String, dynamic>) {
        return null;
      }

      final background = ColorExtension.fromHex(json['background'] as String);
      final foreground = ColorExtension.fromHex(json['foreground'] as String);

      return CustomTerminalThemesCompanion.insert(
        name: json['name'] as String,
        black: ColorExtension.fromHex(json['black'] as String)!,
        red: ColorExtension.fromHex(json['red'] as String)!,
        green: ColorExtension.fromHex(json['green'] as String)!,
        yellow: ColorExtension.fromHex(json['yellow'] as String)!,
        blue: ColorExtension.fromHex(json['blue'] as String)!,
        purple: ColorExtension.fromHex(json['purple'] as String)!,
        cyan: ColorExtension.fromHex(json['cyan'] as String)!,
        white: ColorExtension.fromHex(json['white'] as String)!,
        brightBlack: ColorExtension.fromHex(json['brightBlack'] as String)!,
        brightRed: ColorExtension.fromHex(json['brightRed'] as String)!,
        brightGreen: ColorExtension.fromHex(json['brightGreen'] as String)!,
        brightYellow: ColorExtension.fromHex(json['brightYellow'] as String)!,
        brightBlue: ColorExtension.fromHex(json['brightBlue'] as String)!,
        brightPurple: ColorExtension.fromHex(json['brightPurple'] as String)!,
        brightCyan: ColorExtension.fromHex(json['brightCyan'] as String)!,
        brightWhite: ColorExtension.fromHex(json['brightWhite'] as String)!,
        background: background!,
        foreground: foreground!,
        cursor: ColorExtension.fromHex(json['cursorColor'] as String)!,
        cursorText: background, // Windows Terminal does not have a cursor text color, so we use the background color as a fallback
        selectionForeground: foreground, // same for selection foreground
        selectionBackground: ColorExtension.fromHex(
          json['selectionBackground'] as String,
        )!,
      );
    } catch (e) {
      logger.warning('Failed to parse theme $fileName: $e');
      return null;
    }
  }
}
