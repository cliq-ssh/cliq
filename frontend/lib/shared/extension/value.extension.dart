import 'package:drift/drift.dart';

extension ValueExtension<T> on Value<T> {
  static Value<T> absentIfSame<T>(T value, T? compareTo) {
    if (value == compareTo) {
      return Value.absent();
    }
    return Value(value);
  }

  static Value<T> absentIfNullOrSame<T>(T? value, [Value<T>? compareTo]) {
    T? val = value;
    if (val is Iterable && val.isEmpty) {
      return Value.absent();
    }

    if (val is String) {
      if (val.trim().isEmpty) {
        return Value.absent();
      }
      val = val.trim() as T;
    }

    if (val == compareTo?.value) {
      return Value.absent();
    }

    return Value.absentIfNull(val);
  }
}
