import 'dart:ui';

import 'package:drift/drift.dart';

import '../../../shared/data/database.dart';

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
        json['cursor'] == null ||
        json['selectionBackground'] == null ||
        json['background'] == null) {
      return null;
    }

    return CustomTerminalThemesCompanion(
      id: Value(json['id'] as DbId),
      name: Value(json['name'] as String),
      blackColor: Value(Color(json['black'] as int)),
      redColor: Value(Color(json['red'] as int)),
      greenColor: Value(Color(json['green'] as int)),
      yellowColor: Value(Color(json['yellow'] as int)),
      blueColor: Value(Color(json['blue'] as int)),
      purpleColor: Value(Color(json['purple'] as int)),
      cyanColor: Value(Color(json['cyan'] as int)),
      whiteColor: Value(Color(json['white'] as int)),
      brightBlackColor: Value(Color(json['brightBlack'] as int)),
      brightRedColor: Value(Color(json['brightRed'] as int)),
      brightGreenColor: Value(Color(json['brightGreen'] as int)),
      brightYellowColor: Value(Color(json['brightYellow'] as int)),
      brightBlueColor: Value(Color(json['brightBlue'] as int)),
      brightPurpleColor: Value(Color(json['brightPurple'] as int)),
      brightCyanColor: Value(Color(json['brightCyan'] as int)),
      brightWhiteColor: Value(Color(json['brightWhite'] as int)),
      foregroundColor: Value(Color(json['foreground'] as int)),
      cursorColor: Value(Color(json['cursor'] as int)),
      selectionBackgroundColor: Value(
        Color(json['selectionBackground'] as int),
      ),
      backgroundColor: Value(Color(json['background'] as int)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id.value,
      'name': name.value,
      'black': blackColor.value,
      'red': redColor.value,
      'green': greenColor.value,
      'yellow': yellowColor.value,
      'blue': blueColor.value,
      'purple': purpleColor.value,
      'cyan': cyanColor.value,
      'white': whiteColor.value,
      'brightBlack': brightBlackColor.value,
      'brightRed': brightRedColor.value,
      'brightGreen': brightGreenColor.value,
      'brightYellow': brightYellowColor.value,
      'brightBlue': brightBlueColor.value,
      'brightPurple': brightPurpleColor.value,
      'brightCyan': brightCyanColor.value,
      'brightWhite': brightWhiteColor.value,
      'foreground': foregroundColor.value,
      'cursor': cursorColor.value,
      'selectionBackground': selectionBackgroundColor.value,
      'background': backgroundColor.value,
    };
  }
}
