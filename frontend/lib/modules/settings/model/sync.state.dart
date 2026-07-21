import 'dart:async';

import 'package:cliq_api/cliq_api.dart';

class SyncState {
  final CliqClient? api;
  final ServerConfigurationResponse? config;
  final Timer? refreshTimer;
  final Timer? pullTimer;

  const SyncState({
    required this.api,
    required this.config,
    required this.refreshTimer,
    required this.pullTimer,
  });

  SyncState.initial()
    : api = null,
      config = null,
      refreshTimer = null,
      pullTimer = null;

  bool get isConnected => api != null && config != null;

  SyncState copyWith({
    CliqClient? api,
    ServerConfigurationResponse? config,
    Timer? refreshTimer,
    Timer? pullTimer,
  }) {
    return SyncState(
      api: api ?? this.api,
      config: config ?? this.config,
      refreshTimer: refreshTimer ?? this.refreshTimer,
      pullTimer: pullTimer ?? this.pullTimer,
    );
  }
}
