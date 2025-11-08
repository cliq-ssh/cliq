import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'model/page_path.model.dart';

extension BuildContextExtension on BuildContext {
  void goPath(PagePath path, {Object? extra}) {
    go(path.fullPath, extra: extra);
  }

  Future<T?> pushPath<T extends Object?>(PagePath path, {Object? extra}) {
    return push(path.fullPath, extra: extra);
  }
}
