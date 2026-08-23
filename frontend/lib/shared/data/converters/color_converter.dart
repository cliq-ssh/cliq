import 'dart:ui';

import 'package:drift/drift.dart';

class ColorConverter extends TypeConverter<Color, int> {
  const new();

  @override
  Color fromSql(int fromDb) => Color(fromDb);

  @override
  int toSql(Color value) => value.toARGB32();
}
