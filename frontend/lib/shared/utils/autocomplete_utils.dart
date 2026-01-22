final class AutocompleteUtils {
  const AutocompleteUtils._();

  static String toAutocompleteString(int id, String label) {
    return '${label.trim()} ($id)';
  }

  static (int?, String?) fromAutocompleteString(String value) {
    final match = RegExp(r'^(.*) \((\d+)\)$').firstMatch(value);
    if (match != null) {
      final label = match.group(1)!.trim();
      final id = int.parse(match.group(2)!);
      return (id, label);
    }
    return (null, null);
  }
}
