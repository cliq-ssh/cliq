enum ReleaseChannel {
  dev,
  edge,
  beta,
  prod;

  static ReleaseChannel parse(String value) {
    return switch (value) {
      'edge' => .edge,
      'beta' => .beta,
      'prod' => .prod,
      _ => .dev,
    };
  }
}

class BuildMetadata {
  // The private constructor keeps this compile-time metadata namespace static.
  new _();

  static const version = String.fromEnvironment(
    'CLIQ_VERSION',
    defaultValue: '0.0.0',
  );

  static const buildNumber = int.fromEnvironment(
    'CLIQ_BUILD_NUMBER',
    defaultValue: 0,
  );

  static const gitSha = String.fromEnvironment(
    'CLIQ_GIT_SHA',
    defaultValue: 'dev',
  );

  static const gitShaShort = String.fromEnvironment(
    'CLIQ_GIT_SHA_SHORT',
    defaultValue: 'dev',
  );

  static const _releaseChannelValue = String.fromEnvironment(
    'CLIQ_RELEASE_CHANNEL',
    defaultValue: 'dev',
  );

  static const releaseChannelValue = _releaseChannelValue;
  static final releaseChannel = ReleaseChannel.parse(_releaseChannelValue);
}
