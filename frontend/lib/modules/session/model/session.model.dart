import '../../../shared/data/sqlite/database.dart';

class SSHSession {
  final int id;
  final Connection? connection;

  SSHSession.empty({required this.id}) : connection = null;

  const SSHSession({required this.id, required this.connection});

  String get effectiveName =>
      connection?.label ?? connection?.address ?? 'Unnamed Session $id';
}
