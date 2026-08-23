import 'package:cliq/shared/model/router.model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<Router> routerProvider = Provider((ref) => Router(ref));
