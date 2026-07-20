class LoginStartResponse {
  final String publicB;
  final String salt;
  final String authenticationSessionToken;

  const LoginStartResponse({
    required this.publicB,
    required this.salt,
    required this.authenticationSessionToken,
  });

  factory LoginStartResponse.fromJson(Map<String, dynamic> json) {
    return LoginStartResponse(
      publicB: json['publicB'] as String,
      salt: json['salt'] as String,
      authenticationSessionToken: json['authenticationSessionToken'] as String,
    );
  }
}
