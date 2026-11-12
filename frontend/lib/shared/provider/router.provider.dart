import 'package:cliq/shared/model/router.model.dart';
import 'package:cliq/shared/provider/window_scope.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<Router> routerProvider = Provider(
  (ref) => Router(ref),
  dependencies: [currentWindowIdProvider],
);
