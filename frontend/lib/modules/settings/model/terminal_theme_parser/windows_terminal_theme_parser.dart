import 'dart:convert';

import 'package:cliq/modules/settings/model/terminal_theme_parser/terminal_theme_parser.dart';
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

  const WindowsTerminalThemeParser();

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
      return CustomTerminalThemesCompanion.insert(
        name: json['name'] as String,
        blackColor: ColorExtension.fromHex(json['black'] as String)!,
        redColor: ColorExtension.fromHex(json['red'] as String)!,
        greenColor: ColorExtension.fromHex(json['green'] as String)!,
        yellowColor: ColorExtension.fromHex(json['yellow'] as String)!,
        blueColor: ColorExtension.fromHex(json['blue'] as String)!,
        purpleColor: ColorExtension.fromHex(json['purple'] as String)!,
        cyanColor: ColorExtension.fromHex(json['cyan'] as String)!,
        whiteColor: ColorExtension.fromHex(json['white'] as String)!,
        brightBlackColor: ColorExtension.fromHex(
          json['brightBlack'] as String,
        )!,
        brightRedColor: ColorExtension.fromHex(json['brightRed'] as String)!,
        brightGreenColor: ColorExtension.fromHex(
          json['brightGreen'] as String,
        )!,
        brightYellowColor: ColorExtension.fromHex(
          json['brightYellow'] as String,
        )!,
        brightBlueColor: ColorExtension.fromHex(json['brightBlue'] as String)!,
        brightPurpleColor: ColorExtension.fromHex(
          json['brightPurple'] as String,
        )!,
        brightCyanColor: ColorExtension.fromHex(json['brightCyan'] as String)!,
        brightWhiteColor: ColorExtension.fromHex(
          json['brightWhite'] as String,
        )!,
        backgroundColor: ColorExtension.fromHex(json['background'] as String)!,
        foregroundColor: ColorExtension.fromHex(json['foreground'] as String)!,
        cursorColor: ColorExtension.fromHex(json['cursorColor'] as String)!,
        selectionBackgroundColor: ColorExtension.fromHex(
          json['selectionBackground'] as String,
        )!,
      );
    } catch (e) {
      logger.warning('Failed to parse theme $fileName: $e');
      return null;
    }
  }
}
