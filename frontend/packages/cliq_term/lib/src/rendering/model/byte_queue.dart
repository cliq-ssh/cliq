/// A simple queue for bytes (characters) that allows peeking, consuming, and rolling back.
class ByteQueue {
  final StringBuffer _buf = StringBuffer();
  String _str = '';
  int _pos = 0;

  bool get isEmpty {
    _ensureRead();
    return _pos >= _str.length;
  }

  bool get isNotEmpty => !isEmpty;
  int get position => _pos;

  /// Returns the number of characters currently in the queue (including unread string and buffer).
  int get length => (_str.length - _pos) + _buf.length;

  void _ensureRead() {
    if (_pos >= _str.length && _buf.isNotEmpty) {
      _str = _buf.toString();
      _buf.clear();
      _pos = 0;
    }
  }

  /// Add new input to the queue.
  void add(String input) {
    _buf.write(input);
  }

  /// Return the next byte without consuming it.
  int peek() {
    _ensureRead();
    return _str.codeUnitAt(_pos);
  }

  /// Consume and return the next byte, advancing the position by 1.
  int consume() {
    _ensureRead();
    return _str.codeUnitAt(_pos++);
  }

  /// Move the position back by [count] characters, without going below 0.
  void rollback(int count) {
    _pos = (_pos - count).clamp(0, _str.length);
  }

  /// Save the current position to allow rolling back to it later.
  void savePosition(int pos) {
    _pos = pos;
  }
}
