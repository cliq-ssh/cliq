class CsiParseResult {
  List<int?> params = [];
  String? leader;
  String intermediates = '';
  int finalByteCode = 0;
}

/// Parser for Control Sequence Introducer (CSI) sequences.
class CsiParser {
  const CsiParser();

  CsiParseResult parseCsi(String body) {
    if (body.isEmpty) {
      throw ArgumentError('Empty CSI body');
    }
    if (body.codeUnitAt(0) != '['.codeUnitAt(0)) {
      throw ArgumentError('CSI body must start with "["');
    }
    if (body.length < 2) {
      throw ArgumentError('CSI body too short');
    }

    final result = CsiParseResult();

    final finalIndex = body.length - 1;
    final outFinal = body.codeUnitAt(finalIndex);
    result.finalByteCode = outFinal;

    int i = 1; // start after [
    final middleEnd = finalIndex;

    if (i < middleEnd) {
      final cu = body.codeUnitAt(i);
      if (cu == '?'.codeUnitAt(0) ||
          cu == '>'.codeUnitAt(0) ||
          cu == '='.codeUnitAt(0) ||
          cu == '!'.codeUnitAt(0)) {
        result.leader = String.fromCharCode(cu);
        i++;
      }
    }

    final int paramStart = i;
    int paramEnd = i;
    while (paramEnd < middleEnd) {
      final cu = body.codeUnitAt(paramEnd);
      if (cu >= 0x20 && cu <= 0x2F) break;
      paramEnd++;
    }

    // extract params
    if (paramEnd > paramStart) {
      final paramsPart = body.substring(paramStart, paramEnd);
      final tokens = paramsPart.split(';');
      for (final t in tokens) {
        if (t.isEmpty) {
          result.params.add(null);
        } else {
          final n = int.tryParse(t);
          result.params.add(n);
        }
      }
    }

    // extract intermediates
    final StringBuffer intermediates = StringBuffer();
    int intermediatesIndex = paramEnd;
    while (intermediatesIndex < middleEnd) {
      final cu = body.codeUnitAt(intermediatesIndex);
      if (cu >= 0x20 && cu <= 0x2F) {
        intermediates.writeCharCode(cu);
        intermediatesIndex++;
      } else {
        break;
      }
    }
    result.intermediates = intermediates.toString();

    return result;
  }
}
