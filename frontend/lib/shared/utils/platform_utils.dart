import 'dart:io';

final class PlatformUtils {
  const PlatformUtils._();

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;
  static bool get isDesktop => !isMobile;
}
