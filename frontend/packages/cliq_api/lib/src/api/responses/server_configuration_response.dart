class ServerConfigurationResponse {
  final String serverVersion;
  final String? oidcUrl;
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
      oidcUrl: json['oidcUrl'],
      localAuthProperties: LocalAuthProperties.fromJson(
        json['localAuthProperties'],
      ),
      authExchangeDurationSeconds: json['authExchangeDurationSeconds'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverVersion': serverVersion,
      'oidcUrl': oidcUrl,
      'localAuthProperties': localAuthProperties.toJson(),
      'authExchangeDurationSeconds': authExchangeDurationSeconds,
    };
  }

  @override
  String toString() => toJson().toString();
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

  Map<String, dynamic> toJson() {
    return {'registration': registration, 'login': login};
  }

  @override
  String toString() => toJson().toString();
}
