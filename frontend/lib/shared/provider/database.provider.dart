import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/database.dart';

final Provider<CliqDatabase> databaseProvider = Provider(
  (ref) => CliqDatabase(),
);
