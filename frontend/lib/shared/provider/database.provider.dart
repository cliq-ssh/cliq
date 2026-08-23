import 'package:cliq/shared/data/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<CliqDatabase> databaseProvider = Provider(
  (ref) => CliqDatabase(),
);
