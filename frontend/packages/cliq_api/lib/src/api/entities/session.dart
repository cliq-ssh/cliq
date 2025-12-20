import 'cliq_entity_impl.dart';

abstract class Session extends CliqEntity {
  int get id;
  String get token;
  String? get name;
  String get userAgent;
  DateTime get createdAt;
}
