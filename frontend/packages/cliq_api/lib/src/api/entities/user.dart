import 'cliq_entity_impl.dart';

abstract class User extends CliqEntity {
  int get id;
  String get email;
  String get username;
  DateTime get createdAt;
  DateTime get updatedAt;
}
