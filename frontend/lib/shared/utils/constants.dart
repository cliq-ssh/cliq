import 'dart:io';
import 'dart:ui';

final class Constants {
  const new _();

  static const String defaultTitle = 'cliq';

  static const String githubUrl = 'https://github.com/cliq-ssh/cliq';
  static const String githubCreateIssueUrl = '$githubUrl/issues/new';
  static const String weblateUrl = 'https://i18n.cliq.sh/projects/cliq';

  static const defaultMaxScrollbackLines = 2_000;
  static const minScrollbackLines = 0;
  static const maxScrollbackLines = 100_000;

  static const cursorMinBlinkInterval = 100;
  static const cursorMaxBlinkInterval = 2000;
  static const cursorMinBlinkTimeout = 0;
  static const cursorMaxBlinkTimeout = 3600;

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

  /// A map of supported locales, where the key is the display name of the locale and the value is the
  /// corresponding [Locale] object.
  static const Map<String, Locale> supportedLocales = {
    'English (United States)': Locale('en', 'US'),
    'Deutsch': Locale('de', 'DE'),
    'Polski': Locale('pl'),
  };

  /// A map of file extensions to their corresponding Uniform Type Identifiers (UTIs).
  static const Map<String, String> extensionToUniformTypeIdentifier = {
    '': 'public.plain-text',
    'txt': 'public.plain-text',
    'json': 'public.json',
    'conf': 'public.plain-text',
  };
}
