class TokenResponse {
  final int id;
  final String name;
  final DateTime? lastUsedAt;
  final DateTime expiresAt;
  final DateTime createdAt;
  final String accessToken;
  final String refreshToken;

  const TokenResponse({
    required this.id,
    required this.name,
    required this.lastUsedAt,
    required this.expiresAt,
    required this.createdAt,
    required this.accessToken,
    required this.refreshToken,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    return TokenResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      lastUsedAt: json['lastUsedAt'] != null
          ? DateTime.parse(json['lastUsedAt'] as String)
          : null,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }
}
