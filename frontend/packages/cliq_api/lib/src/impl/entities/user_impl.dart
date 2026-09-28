import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_api/src/impl/entities/cliq_entity_impl.dart';

class const UserImpl(
  super.api, {
  @override required final int id,
  @override required final String username,
  @override required final String email,
  @override required final DateTime createdAt,
  @override required final DateTime updatedAt,
}) extends CliqEntityImpl implements User;
