import 'package:cliq_api/src/api/entities/cliq_entity_impl.dart';

abstract class PartialVault extends CliqEntity {
  String get id;
  String get version;
  DateTime get createdAt;
  DateTime get updatedAt;
}
