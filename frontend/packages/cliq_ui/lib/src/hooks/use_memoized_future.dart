import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

AsyncSnapshot<T> useMemoizedFuture<T>(
  Future<T> Function() futureBuilder, [
  List<Object?> keys = const [],
]) {
  final future = useMemoized(futureBuilder, keys);
  return useFuture(future);
}
