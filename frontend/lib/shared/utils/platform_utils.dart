import 'dart:io';

import 'package:flutter/foundation.dart';

final class PlatformUtils {
  const PlatformUtils._();

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => !isMobile && !isWeb;
  static bool get isWeb => kIsWeb;
}
