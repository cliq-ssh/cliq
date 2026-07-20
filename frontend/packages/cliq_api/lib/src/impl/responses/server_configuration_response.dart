class ServerConfigurationResponse {
  final String serverVersion;
  final String oidcUrl;
  final LocalAuthProperties localAuthProperties;
  final int authExchangeDurationSeconds;

  const ServerConfigurationResponse({
    required this.serverVersion,
    required this.oidcUrl,
    required this.localAuthProperties,
    required this.authExchangeDurationSeconds,
  });

  factory ServerConfigurationResponse.fromJson(Map<String, dynamic> json) {
    return ServerConfigurationResponse(
      serverVersion: json['serverVersion'] as String,
      oidcUrl: json['oidcUrl'] as String,
      localAuthProperties: LocalAuthProperties.fromJson(
        json['localAuthProperties'],
      ),
      authExchangeDurationSeconds: json['authExchangeDurationSeconds'] as int,
    );
  }
}

class LocalAuthProperties {
  final bool registration;
  final bool login;

  const LocalAuthProperties({required this.registration, required this.login});

  factory LocalAuthProperties.fromJson(Map<String, dynamic> json) {
    return LocalAuthProperties(
      registration: json['registration'] as bool,
      login: json['login'] as bool,
    );
  }
}
