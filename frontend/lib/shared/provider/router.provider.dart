import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../model/router.model.dart';

final Provider<Router> routerProvider = Provider((ref) => Router(ref));
