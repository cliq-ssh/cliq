import 'package:cliq/shared/data/sqlite/database.dart';

import '../../../shared/model/identity_full.model.dart';

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

  Connection toBaseClass() {
    return Connection(
      id: id,
      address: address,
      port: port,
      identityId: identity?.id,
      username: username,
      credentialId: credential?.id,
      label: label,
      icon: icon,
      color: color,
    );
  }
}
