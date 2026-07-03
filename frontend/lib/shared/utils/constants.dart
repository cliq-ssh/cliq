final class Constants {
  const Constants._();

  static const String githubUrl = 'https://github.com/cliq-ssh/cliq';
  static const String githubCreateIssueUrl = '$githubUrl/issues/new';

  /// The threshold size (in bytes) for considering a file as "large" when downloading over SFTP.
  /// Files larger than this size will trigger a warning if the user has enabled the large downloads warning setting.
  static const int largeFileSizeThreshold = 50 * 1024 * 1024;
}
