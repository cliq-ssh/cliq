import 'package:cliq_term/cliq_term.dart';
import 'package:drift/drift.dart';

class TerminalTypographyConverter
    extends TypeConverter<TerminalTypography, String> {
  const TerminalTypographyConverter();

  @override
  TerminalTypography fromSql(String fromDb) {
    final parts = fromDb.split(';');
    return TerminalTypography(
      fontSize: int.parse(parts[0]),
      fontFamily: parts[1],
    );
  }

  @override
  String toSql(TerminalTypography value) =>
      '${value.fontSize};${value.fontFamily}';
}
