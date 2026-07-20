import 'package:cliq_api/cliq_api.dart';

class SyncState {
  final CliqClient? api;
  final ServerConfigurationResponse? config;

  const SyncState({required this.api, required this.config});

  SyncState.initial() : api = null, config = null;

  bool get isConnected => api != null && config != null;

  SyncState copyWith({CliqClient? api, ServerConfigurationResponse? config}) {
    return SyncState(api: api ?? this.api, config: config ?? this.config);
  }
}
