/// A simple queue for bytes (characters) that allows peeking, consuming, and rolling back.
class ByteQueue {
  final StringBuffer _buf = StringBuffer();
  String _str = '';
  int _pos = 0;

  bool get isEmpty => _pos >= _str.length;
  bool get isNotEmpty => !isEmpty;
  int get position => _pos;

  /// Add new input to the queue, preserving any unread portion of the current string.
  void add(String input) {
    if (_pos < _str.length) {
      // carry over unread portion
      _buf.write(_str.substring(_pos));
    }
    _buf.write(input);
    _str = _buf.toString();
    _buf.clear();
    _pos = 0;
  }

  /// Return the next byte without consuming it.
  int peek() => _str.codeUnitAt(_pos);

  /// Consume and return the next byte, advancing the position by 1.
  int consume() => _str.codeUnitAt(_pos++);

  /// Move the position back by [count] characters, without going below 0.
  void rollback(int count) => _pos = (_pos - count).clamp(0, _str.length);

  /// Save the current position to allow rolling back to it later.
  void savePosition(int pos) => _pos = pos;
}
