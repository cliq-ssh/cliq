/// A simple queue for bytes (characters) that allows peeking, consuming, and rolling back.
class ByteQueue {
  final StringBuffer _incoming = StringBuffer();
  String _active = '';
  int _pos = 0;

  bool get isEmpty {
    if (_pos < _active.length) return false;
    if (_incoming.isEmpty) return true;
    _active = _incoming.toString();
    _incoming.clear();
    _pos = 0;
    return _active.isEmpty;
  }

  bool get isNotEmpty => !isEmpty;
  int get position => _pos;

  /// Returns the number of characters currently in the queue.
  int get length => (_active.length - _pos) + _incoming.length;

  /// Add new input to the queue efficiently.
  void add(String input) {
    if (input.isEmpty) return;
    _incoming.write(input);
  }

  /// Return the next byte without consuming it.
  int peek() {
    if (isEmpty) throw StateError('Queue is empty');
    return _active.codeUnitAt(_pos);
  }

  /// Consume and return the next byte, advancing the position by 1.
  int consume() {
    if (isEmpty) throw StateError('Queue is empty');
    return _active.codeUnitAt(_pos++);
  }

  /// Save the current position to allow rolling back to it later.
  void savePosition(int pos) {
    _pos = pos;
  }
}
