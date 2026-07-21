import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_api/src/impl/entities/cliq_entity_impl.dart';

class UserImpl extends CliqEntityImpl implements User {
  @override
  final int id;
  @override
  final String username;
  @override
  final String email;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  const UserImpl(
    super.api, {
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });
}
