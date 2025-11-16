import '../../../data/database.dart';
import '../../../shared/model/identity_full.model.dart';

/// Model class that better wraps the [FindFullConnectionByIdResult] class.
class ConnectionFull {
  final int id;
  final String address;
  final int port;
  final IdentityFull? identity;
  final String? username;
  final Credential? credential;
  final String? label;
  final String? icon;
  final String? color;

  String get effectiveUsername => username ?? identity!.username;
  Credential? get effectiveCredential => credential ?? identity?.credential;

  const ConnectionFull({
    required this.id,
    required this.address,
    required this.port,
    this.identity,
    this.username,
    this.credential,
    this.label,
    this.icon,
    this.color,
  });
}
