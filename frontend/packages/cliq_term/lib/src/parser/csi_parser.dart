class CSIParseResult {
  /// Number of characters consumed starting at '['
  final int consumed;
  final List<String> params;
  final String finalByte;

  const CSIParseResult(this.consumed, this.params, this.finalByte);
}

class CSIParser {
  const CSIParser._();

  static CSIParseResult? parse(String input, int start) {
    if (start >= input.length || input[start] != '[') return null;
    int i = start + 1;
    int paramsStart = i;

    while (i < input.length) {
      final cu = input.codeUnitAt(i);
      if (cu >= 0x40 && cu <= 0x7E) break; // final byte
      i++;
    }

    // simply return if incomplete
    if (i >= input.length) return null;

    final paramStr = input.substring(paramsStart, i);
    final params = paramStr.isEmpty ? <String>[] : paramStr.split(';');
    final finalByte = input[i];
    return CSIParseResult(i - start + 1, params, finalByte);
  }
}
