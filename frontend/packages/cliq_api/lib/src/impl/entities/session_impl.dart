import 'package:cliq_api/cliq_api.dart';

import 'cliq_entity_impl.dart';

class SessionImpl extends CliqEntityImpl implements Session {
  @override
  final int id;
  @override
  final String token;
  @override
  final String? name;
  @override
  final String userAgent;
  @override
  final DateTime createdAt;

  const SessionImpl(
    super.api, {
    required this.id,
    required this.token,
    required this.name,
    required this.userAgent,
    required this.createdAt,
  });
}
