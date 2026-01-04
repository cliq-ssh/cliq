import '../../../shared/data/database.dart';

extension ConnectionExtension on Connection {
  String get effectiveName => label ?? address;
}
