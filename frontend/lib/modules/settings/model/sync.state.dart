import 'package:cliq_api/cliq_api.dart';

class SyncState {
  final CliqClient? api;
  final DateTime? lastSync;

  const SyncState({required this.api, required this.lastSync});

  SyncState.initial() : api = null, lastSync = null;

  SyncState copyWith({CliqClient? api, DateTime? lastSync}) {
    return SyncState(api: api ?? this.api, lastSync: lastSync ?? this.lastSync);
  }
}
