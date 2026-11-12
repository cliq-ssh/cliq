import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart' as pp;

/// A wrapper around the `path_provider` package to separate debug and release builds.
final class PathProvider {
  /// Path to a directory where the application may place application-specific cache files.
  ///
  /// In debug mode this is a `debug` subfolder of what [pp.getApplicationCacheDirectory] returns.
  static final Future<Directory> applicationSupportDirectory =
      _resolveApplicationCacheDirectory();

  static Future<Directory> _resolveApplicationCacheDirectory() async {
    final base = await pp.getApplicationCacheDirectory();
    if (kDebugMode) {
      return Directory('${base.path}/debug').create(recursive: true);
    }

    return base;
  }
}
