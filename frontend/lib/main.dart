import 'package:cliq/routing/provider/router.provider.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database.dart';
import 'modules/settings/provider/theme.provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    _initLogger();
  }

  CliqDatabase.init();
  SharedPreferences.setPrefix('cliq.');
  await KeyValueStore.init();

  runApp(const ProviderScope(child: CliqApp()));
}

void _initLogger() {
  String getColorFromLevel(Level level) {
    if (level >= Level.SEVERE) return '\x1B[1;31m';
    if (level >= Level.WARNING) return '\x1B[33m';
    if (level >= Level.INFO) return '\x1B[32m';
    if (level >= Level.CONFIG) return '\x1B[36m';
    if (level == Level.FINE) return '\x1B[37m';
    if (level == Level.FINER) return '\x1B[90m';
    if (level == Level.FINEST) return '\x1B[2;90m';

    return '\x1B[90m';
  }

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final color = getColorFromLevel(record.level);
    const reset = '\x1B[0m';
    final timeString = record.time.toIso8601String().substring(11, 23);

    // always have room for long logger names and levels
    if (kDebugMode) {
      print(
        '$color${record.level.name.padRight(7)}  ${record.loggerName.padRight(24)}  $timeString: ${record.message}$reset',
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
    final theme = ref.watch(themeProvider);

    return MaterialApp.router(
      routerConfig: router.goRouter,
      debugShowCheckedModeBanner: false,
      themeMode: theme.themeMode,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      builder: (context, child) {
        return FAnimatedTheme(
          data: theme.activeTheme.getThemeWithMode(theme.themeMode),
          child: FToaster(child: child ?? Container()),
        );
      },
    );
  }
}
