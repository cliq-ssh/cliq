import 'package:cliq_api/src/api/entities/cliq_entity_impl.dart';

abstract class UserConfig extends CliqEntity {
  String get configuration;
  DateTime get createdAt;
  DateTime get updatedAt;
}
