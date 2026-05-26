const _decSpecGraphicsMap = <int, int>{
  0x60: 0x25C6,
  0x61: 0x2592,
  0x62: 0x2409,
  0x63: 0x240C,
  0x64: 0x240D,
  0x65: 0x240A,
  0x66: 0x00B0,
  0x67: 0x00B1,
  0x68: 0x2424,
  0x69: 0x240B,
  0x6a: 0x2518,
  0x6b: 0x2510,
  0x6c: 0x250C,
  0x6d: 0x2514,
  0x6e: 0x253C,
  0x6f: 0x23BA,
  0x70: 0x23BB,
  0x71: 0x2500,
  0x72: 0x23BC,
  0x73: 0x23BD,
  0x74: 0x251C,
  0x75: 0x2524,
  0x76: 0x2534,
  0x77: 0x252C,
  0x78: 0x2502,
  0x79: 0x2264,
  0x7a: 0x2265,
  0x7b: 0x03C0,
  0x7c: 0x2260,
  0x7d: 0x00A3,
  0x7e: 0x00B7,
};

class CharsetState {
  final Map<int, int Function(int)> _charsetMap = {};
  int _currentIndex = 0;

  /// Saved state for DECSC/DECRC
  Map<int, int Function(int)> _savedCharsetMap = {};
  int _savedIndex = 0;

  CharsetState();

  CharsetState.copyFrom(CharsetState other) {
    _charsetMap.addAll(other._charsetMap);
    _currentIndex = other._currentIndex;
    _savedCharsetMap = Map.from(other._savedCharsetMap);
    _savedIndex = other._savedIndex;
  }

  int Function(int) _resolveTranslator(int name) {
    return switch (name) {
      0x30 => (c) {
        if (c >= 127) return c;
        return _decSpecGraphicsMap[c] ?? c;
      },
      _ => (c) => c, // 'B' or unknown = ASCII passthrough
    };
  }

  /// Translates a code point using the currently active charset, if any.
  int translate(int codePoint) {
    final translator = _charsetMap[_currentIndex];
    if (translator == null) return codePoint;
    return translator(codePoint);
  }

  void designate(int index, int name) =>
      _charsetMap[index] = _resolveTranslator(name);
  void use(int index) => _currentIndex = index;

  /// Saves the current charset state
  void save() {
    _savedCharsetMap = Map.from(_charsetMap);
    _savedIndex = _currentIndex;
  }

  /// Restores the charset state saved by the most recent [save] call
  void restore() {
    _charsetMap
      ..clear()
      ..addAll(_savedCharsetMap);
    _currentIndex = _savedIndex;
  }
}
