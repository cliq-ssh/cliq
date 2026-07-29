class ServerConfigurationResponse {
  final String serverVersion;
  final String? oidcUrl;
  final LocalAuthProperties localAuthProperties;
  final int authExchangeDurationSeconds;
  final bool emailEnabled;

  const ServerConfigurationResponse({
    required this.serverVersion,
    required this.oidcUrl,
    required this.localAuthProperties,
    required this.authExchangeDurationSeconds,
    required this.emailEnabled,
  });

  factory ServerConfigurationResponse.fromJson(Map<String, dynamic> json) {
    return ServerConfigurationResponse(
      serverVersion: json['serverVersion'] as String,
      oidcUrl: json['oidcUrl'],
      localAuthProperties: LocalAuthProperties.fromJson(
        json['localAuthProperties'],
      ),
      authExchangeDurationSeconds: json['authExchangeDurationSeconds'] as int,
      emailEnabled: json['emailEnabled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverVersion': serverVersion,
      'oidcUrl': oidcUrl,
      'localAuthProperties': localAuthProperties.toJson(),
      'authExchangeDurationSeconds': authExchangeDurationSeconds,
      'emailEnabled': emailEnabled,
    };
  }

  @override
  String toString() => toJson().toString();
}

class LocalAuthProperties {
  final bool enabled;
  final bool registrationEnabled;

  const LocalAuthProperties({
    required this.enabled,
    required this.registrationEnabled,
  });

  factory LocalAuthProperties.fromJson(Map<String, dynamic> json) {
    return LocalAuthProperties(
      enabled: json['enabled'] as bool,
      registrationEnabled: json['registrationEnabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {'enabled': enabled, 'registrationEnabled': registrationEnabled};
  }

  @override
  String toString() => toJson().toString();
}
