import 'package:cliq/data/sqlite/database.dart';
import 'package:cliq/routing/router.provider.dart';
import 'package:cliq/data/store.dart';
import 'package:cliq_ui/cliq_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    _initLogger();
  }

  CliqDatabase.init();
  await KeyValueStore.init();

  runApp(const ProviderScope(child: CliqApp()));
}

void _initLogger() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print(
        '${record.loggerName} [${record.level.name}] [${record.time.toIso8601String()}]: ${record.message}',
      );
    }
  });
}

class CliqApp extends StatefulHookConsumerWidget {
  const CliqApp({super.key});

  @override
  ConsumerState<CliqApp> createState() => _CliqAppState();
}

class _CliqAppState extends ConsumerState<CliqApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(systemNavigationBarColor: Colors.transparent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router.goRouter,
      debugShowCheckedModeBanner: false,
      builder: (context, child) =>
          CliqTheme(data: CliqThemes.standard.dark, child: child!),
    );
  }
}
