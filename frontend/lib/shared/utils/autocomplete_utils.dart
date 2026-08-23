import 'package:cliq/shared/data/database.dart';

final class AutocompleteUtils {
  const new _();

  static String toAutocompleteString(DbId id, String label) {
    return '${label.trim()} ($id)';
  }

  static (DbId?, String?) fromAutocompleteString(String value) {
    final match = RegExp(r'^(.*) \((.*)\)$').firstMatch(value);
    if (match != null) {
      final label = match.group(1)!.trim();
      final id = match.group(2)!;
      return (id, label);
    }
    return (null, null);
  }
}
