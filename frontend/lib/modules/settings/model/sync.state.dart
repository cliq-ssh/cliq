import 'dart:async';

import 'package:cliq_api/cliq_api.dart';

class SyncState {
  final CliqClient? api;
  final ServerConfigurationResponse? config;
  final Timer? refreshTimer;

  const SyncState({
    required this.api,
    required this.config,
    required this.refreshTimer,
  });

  SyncState.initial() : api = null, config = null, refreshTimer = null;

  bool get isConnected => api != null && config != null;

  SyncState copyWith({
    CliqClient? api,
    ServerConfigurationResponse? config,
    Timer? refreshTimer,
  }) {
    return SyncState(
      api: api ?? this.api,
      config: config ?? this.config,
      refreshTimer: refreshTimer ?? this.refreshTimer,
    );
  }
}
