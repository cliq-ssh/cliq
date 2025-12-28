class RingBuffer<T> {
  final int maxSize;
  final List<T?> _buffer;

  int _start = 0;
  int _length = 0;

  RingBuffer(this.maxSize)
    : _buffer = List.filled(maxSize, null as T?, growable: false);

  int get length => _length;
  int get capacity => maxSize;
  bool get isFull => _length == maxSize;
  bool get isEmpty => _length == 0;

  void add(T item) {
    final end = (_start + _length) % maxSize;
    _buffer[end] = item;
    if (isFull) {
      // Overwrite oldest, advance start to next oldest
      _start = (_start + 1) % maxSize;
    } else {
      _length++;
    }
  }

  void prepend(T item) {
    // Move start backward by one position (circular).
    _start = (_start - 1 + maxSize) % maxSize;
    _buffer[_start] = item;
    if (!isFull) {
      _length++;
    }
  }

  void clear() {
    _start = 0;
    _length = 0;
    for (var i = 0; i < maxSize; i++) {
      _buffer[i] = null;
    }
  }

  void forEach(void Function(T item) action) {
    for (var i = 0; i < _length; i++) {
      final idx = (_start + i) % maxSize;
      final v = _buffer[idx];
      if (v != null) action(v);
    }
  }

  T operator [](int index) {
    if (index < 0 || index >= _length) {
      throw RangeError.index(index, this, 'index', null, _length);
    }
    final idx = (_start + index) % maxSize;
    final v = _buffer[idx];
    if (v == null) throw StateError('No element at index $index');
    return v;
  }

  void operator []=(int index, T value) {
    if (index < 0 || index >= _length) {
      throw RangeError.index(index, this, 'index', null, _length);
    }
    final idx = (_start + index) % maxSize;
    _buffer[idx] = value;
  }
}
