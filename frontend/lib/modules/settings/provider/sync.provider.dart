import 'package:cliq/modules/settings/model/sync.state.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq_api/cliq_api.dart';
import 'package:riverpod/riverpod.dart';

final NotifierProvider<SyncNotifier, SyncState> syncProvider = NotifierProvider(
  SyncNotifier.new,
);

class SyncNotifier extends Notifier<SyncState> {
  Future<void> register(
    RouteOptions routeOptions,
    String username,
    String email,
    String password,
  ) async {
    final api = await CliqClientBuilder(
      routeOptions: routeOptions,
    ).register(username: username, email: email, password: password);
    StoreKey.syncHostUrl.write(routeOptions.hostUri.toString());
    StoreKey.syncToken.write(api.session.token);
    StoreKey.syncEmail.write(email);
    StoreKey.syncPassword.write(password);
    state = state.copyWith(api: api);

    fetchLastUpdated();
  }

  Future<void> login(
    RouteOptions routeOptions,
    String email,
    String password,
  ) async {
    final api = await CliqClientBuilder(
      routeOptions: routeOptions,
    ).login(email: email, password: password);
    StoreKey.syncHostUrl.write(routeOptions.hostUri.toString());
    StoreKey.syncToken.write(api.session.token);
    StoreKey.syncEmail.write(email);
    StoreKey.syncPassword.write(password);
    state = state.copyWith(api: api);

    fetchLastUpdated();
  }

  Future<void> attemptRecover() {
    final hostUrl = StoreKey.syncHostUrl.readSync();
    final token = StoreKey.syncToken.readSync();
    if (hostUrl == null || token == null) {
      return Future.value();
    }
    final routeOptions = RouteOptions()..hostUri = Uri.parse(hostUrl);
    return CliqClientBuilder(
      routeOptions: routeOptions,
    ).loginFromToken(token).then((api) {
      state = state.copyWith(api: api);
      return fetchLastUpdated();
    });
  }

  void logout() {
    StoreKey.syncHostUrl.delete();
    StoreKey.syncToken.delete();
    StoreKey.syncEmail.delete();
    StoreKey.syncPassword.delete();
    state = SyncState.initial();
  }

  Future<void> fetchLastUpdated() async {
    if (state.api == null) throw StateError('API client is not initialized.');
    final lastUpdated = await state.api!.retrieveUserConfigLastUpdated();
    state = state.copyWith(lastSync: lastUpdated);
  }

  @override
  SyncState build() {
    // TODO: attemptRecover();
    return SyncState.initial();
  }
}
