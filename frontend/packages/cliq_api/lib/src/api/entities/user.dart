import 'cliq_entity_impl.dart';

abstract class User extends CliqEntity {
  int get id;
  String get name;
  String get email;
  DateTime get createdAt;
}
