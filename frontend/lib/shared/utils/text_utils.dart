import 'dart:math';

class TextUtils {
  const TextUtils._();

  static String? formatBytes(int? bytes, {int decimals = 2}) {
    if (bytes == null || bytes <= 0) return null;
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / (pow(1024, i))).toStringAsFixed(decimals)} ${suffixes[i]}';
  }
}
