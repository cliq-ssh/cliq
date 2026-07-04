import 'dart:io';
import 'dart:ui';

final class Constants {
  const Constants._();

  static const String githubUrl = 'https://github.com/cliq-ssh/cliq';
  static const String githubCreateIssueUrl = '$githubUrl/issues/new';

  /// The threshold size (in bytes) for considering a file as "large" when downloading over SFTP.
  /// Files larger than this size will trigger a warning if the user has enabled the large downloads warning setting.
  static const int largeFileSizeThreshold = 50 * 1024 * 1024;

  static Directory get sftpTempDirectory {
    final dir = Directory(
      '${Directory.systemTemp.path}${Platform.pathSeparator}cliq_sftp_temp',
    );
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('de', 'DE'),
  ];
}
