import 'package:flutter/cupertino.dart';

extension AsyncSnapshotExtension<T> on AsyncSnapshot<T> {
  R on<R>({
    R Function()? onLoading,
    R Function(Object?)? onError,
    R Function(T data)? onData,
    R? defaultValue,
  }) {
    if (onLoading != null && connectionState == ConnectionState.waiting) {
      return onLoading();
    }
    if (onError != null && hasError) {
      return onError(error);
    }
    if (onData != null && hasData) {
      return onData(data as T);
    }
    if (defaultValue != null) {
      return defaultValue;
    }
    return throw StateError('Invalid state: $this');
  }
}
