import 'package:cliq_api/src/api/entities/cliq_entity_impl.dart';

abstract class Vault extends CliqEntity {
  String get configuration;
  String get version;
  DateTime get createdAt;
  DateTime get updatedAt;
}
