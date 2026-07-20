import 'package:cliq_api/cliq_api.dart';

class SyncState {
  final CliqClient? api;

  const SyncState({required this.api});

  SyncState.initial() : api = null;

  bool get isConnected => api != null;
}
