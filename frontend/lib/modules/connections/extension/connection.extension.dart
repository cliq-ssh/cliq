import '../../../shared/data/sqlite/database.dart';

extension ConnectionExtension on Connection {
  String get effectiveName => label ?? address;
}
