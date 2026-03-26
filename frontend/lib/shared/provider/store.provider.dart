import '../data/store.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter/foundation.dart';

ValueNotifier<T> useStore<T>(StoreKey<T> key) {
  final notifier = useMemoized(
    () => ValueNotifier<T>(KeyValueStore().readSync<T>(key)),
    [key],
  );

  useEffect(() {
    // listen for changes
    final sub = KeyValueStore().streamForKey<T>(key).listen((value) {
      if (notifier.value != value) {
        notifier.value = value;
      }
    });
    return sub.cancel;
  }, [key]);

  useListenable(notifier);

  return notifier;
}
