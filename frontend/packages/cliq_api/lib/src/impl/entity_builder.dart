import 'package:cliq_api/cliq_api.dart';

import 'cliq_client_impl.dart';
import 'entities/session_impl.dart';
import 'entities/user_config_impl.dart';
import 'entities/user_impl.dart';

class EntityBuilder {
  final CliqClientImpl api;

  const EntityBuilder({required this.api});

  User buildUser(Map<String, dynamic> json) {
    return UserImpl(
      api,
      id: json['id'],
      email: json['email'],
      name: json['name'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Session buildSession(Map<String, dynamic> json) {
    return SessionImpl(
      api,
      id: json['id'],
      token: json['token'],
      name: json['name'],
      userAgent: json['userAgent'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  UserConfig buildUserConfig(Map<String, dynamic> json) {
    return UserConfigImpl(
      api,
      configuration: json['configuration'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
