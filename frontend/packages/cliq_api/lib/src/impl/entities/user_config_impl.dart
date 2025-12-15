import 'package:cliq_api/cliq_api.dart';

import 'cliq_entity_impl.dart';

class UserConfigImpl extends CliqEntityImpl implements UserConfig {
  @override
  final String configuration;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  const UserConfigImpl(
    super.api, {
    required this.configuration,
    required this.createdAt,
    required this.updatedAt,
  });
}
