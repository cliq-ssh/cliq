import 'package:cliq/modules/connections/model/connection_color.dart';
import 'package:cliq/modules/connections/model/connection_icon.dart';

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
  final ConnectionIcon icon;
  final ConnectionColor color;
  final String? group;

  String get effectiveUsername => username ?? identity!.username;
  Credential? get effectiveCredential => credential ?? identity?.credential;

  const ConnectionFull({
    required this.id,
    required this.address,
    required this.port,
    required this.icon,
    required this.color,
    this.identity,
    this.username,
    this.credential,
    this.label,
    this.group,
  });
}
