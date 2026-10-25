import 'package:cliq/modules/settings/data/log.service.dart';
import 'package:cliq/shared/provider/database.provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<LogService> logServiceProvider = Provider(
  (ref) => LogService(ref.read(databaseProvider).logsRepository),
);
