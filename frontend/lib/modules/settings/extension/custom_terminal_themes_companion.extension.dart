import 'dart:ui';

import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';

extension CustomTerminalThemesCompanionExtension
    on CustomTerminalThemesCompanion {
  static CustomTerminalThemesCompanion? tryFromJson(
    Map<String, dynamic>? json,
  ) {
    if (json == null ||
        json['id'] == null ||
        json['name'] == null ||
        json['black'] == null ||
        json['red'] == null ||
        json['green'] == null ||
        json['yellow'] == null ||
        json['blue'] == null ||
        json['purple'] == null ||
        json['cyan'] == null ||
        json['white'] == null ||
        json['brightBlack'] == null ||
        json['brightRed'] == null ||
        json['brightGreen'] == null ||
        json['brightYellow'] == null ||
        json['brightBlue'] == null ||
        json['brightPurple'] == null ||
        json['brightCyan'] == null ||
        json['brightWhite'] == null ||
        json['foreground'] == null ||
        json['background'] == null ||
        json['cursor'] == null ||
        json['cursorText'] == null ||
        json['selectionBackground'] == null ||
        json['selectionForeground'] == null) {
      return null;
    }

    return CustomTerminalThemesCompanion(
      id: Value(json['id'] as DbId),
      name: Value(json['name'] as String),
      black: Value(Color(json['black'] as int)),
      red: Value(Color(json['red'] as int)),
      green: Value(Color(json['green'] as int)),
      yellow: Value(Color(json['yellow'] as int)),
      blue: Value(Color(json['blue'] as int)),
      purple: Value(Color(json['purple'] as int)),
      cyan: Value(Color(json['cyan'] as int)),
      white: Value(Color(json['white'] as int)),
      brightBlack: Value(Color(json['brightBlack'] as int)),
      brightRed: Value(Color(json['brightRed'] as int)),
      brightGreen: Value(Color(json['brightGreen'] as int)),
      brightYellow: Value(Color(json['brightYellow'] as int)),
      brightBlue: Value(Color(json['brightBlue'] as int)),
      brightPurple: Value(Color(json['brightPurple'] as int)),
      brightCyan: Value(Color(json['brightCyan'] as int)),
      brightWhite: Value(Color(json['brightWhite'] as int)),
      background: Value(Color(json['background'] as int)),
      foreground: Value(Color(json['foreground'] as int)),
      cursor: Value(Color(json['cursor'] as int)),
      cursorText: Value(Color(json['cursorText'] as int)),
      selectionBackground: Value(Color(json['selectionBackground'] as int)),
      selectionForeground: Value(Color(json['selectionForeground'] as int)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'name': name.value,
      'black': black.value.toARGB32(),
      'red': red.value.toARGB32(),
      'green': green.value.toARGB32(),
      'yellow': yellow.value.toARGB32(),
      'blue': blue.value.toARGB32(),
      'purple': purple.value.toARGB32(),
      'cyan': cyan.value.toARGB32(),
      'white': white.value.toARGB32(),
      'brightBlack': brightBlack.value.toARGB32(),
      'brightRed': brightRed.value.toARGB32(),
      'brightGreen': brightGreen.value.toARGB32(),
      'brightYellow': brightYellow.value.toARGB32(),
      'brightBlue': brightBlue.value.toARGB32(),
      'brightPurple': brightPurple.value.toARGB32(),
      'brightCyan': brightCyan.value.toARGB32(),
      'brightWhite': brightWhite.value.toARGB32(),
      'background': background.value.toARGB32(),
      'foreground': foreground.value.toARGB32(),
      'cursor': cursor.value.toARGB32(),
      'cursorText': cursorText.value.toARGB32(),
      'selectionBackground': selectionBackground.value.toARGB32(),
      'selectionForeground': selectionForeground.value.toARGB32(),
    };
  }
}
