import 'package:drift/drift.dart';

extension ValueExtension<T> on Value<T> {
  static Value<T> absentIfSame<T>(T value, T? compareTo) {
    if (value == compareTo) {
      return Value.absent();
    }
    return Value(value);
  }

  static Value<T> absentIfNullOrEmpty<T>(T? value) {
    if (value is Iterable && value.isEmpty) {
      return Value.absent();
    }

    if (value is String) {
      if (value.trim().isEmpty) {
        return Value.absent();
      }
      value = value.trim() as T;
    }

    return Value.absentIfNull(value);
  }
}
