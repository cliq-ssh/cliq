class LoginFinishResponse {
  final String authExchangeCode;
  final String dataEncryptionKeyUmkWrapped;
  final String publicM2;

  const LoginFinishResponse({
    required this.authExchangeCode,
    required this.dataEncryptionKeyUmkWrapped,
    required this.publicM2,
  });

  factory LoginFinishResponse.fromJson(Map<String, dynamic> json) {
    return LoginFinishResponse(
      authExchangeCode: json['authExchangeCode'] as String,
      dataEncryptionKeyUmkWrapped:
          json['dataEncryptionKeyUmkWrapped'] as String,
      publicM2: json['publicM2'] as String,
    );
  }
}
