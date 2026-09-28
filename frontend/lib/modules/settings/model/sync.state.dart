import 'dart:async';

import 'package:cliq_api/cliq_api.dart';

class const SyncState({
  /// The api instance used to communicate with the server
  required final CliqClient? api,
  /// The [ServerConfigurationResponse] received from the server upon initialization
  required final ServerConfigurationResponse? config,
  required final Timer? refreshTimer,
  required final Timer? pullTimer,
  /// An optional error message if the sync state is in an error state
  required final String? error,
}) {

  const new initial()
    : this(
        api: null,
        config: null,
        refreshTimer: null,
        pullTimer: null,
        error: null,
      );

  /// Whether the sync state is connected
  bool get isConnected => error != null && api != null && config != null;

  SyncState copyWith({
    CliqClient? api,
    ServerConfigurationResponse? config,
    Timer? refreshTimer,
    Timer? pullTimer,
    String? error,
  }) {
    return SyncState(
      api: api ?? this.api,
      config: config ?? this.config,
      refreshTimer: refreshTimer ?? this.refreshTimer,
      pullTimer: pullTimer ?? this.pullTimer,
      error: error ?? this.error,
    );
  }
}
