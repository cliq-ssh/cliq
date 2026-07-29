import 'dart:typed_data';

class StringUtils {
  const StringUtils._();

  static T? tryEnumFromString<T extends Enum>(String? value, List<T> values) {
    if (value == null) {
      return null;
    }
    for (T v in values) {
      if (v.name == value) {
        return v;
      }
    }
    return null;
  }

  /// Converts a [Uint8List] to a hexadecimal string representation.
  static String arrayToHex(Uint8List data) {
    var result = '';
    for (final x in data) {
      var str = '00${x.toRadixString(16)}';
      result += str.substring(str.length - 2, str.length);
    }
    return result;
  }

  static Uint8List hexToArray(String hex) {
    final normalizedHex = hex.length.isOdd ? '0$hex' : hex;
    final length = normalizedHex.length;
    final bytes = Uint8List(length ~/ 2);
    for (var i = 0; i < length; i += 2) {
      final byte = normalizedHex.substring(i, i + 2);
      bytes[i ~/ 2] = int.parse(byte, radix: 16);
    }
    return bytes;
  }
}
