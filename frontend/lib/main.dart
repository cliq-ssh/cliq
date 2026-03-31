import 'dart:async';

import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/model/router.model.dart';
import 'package:cliq/shared/provider/router.provider.dart';
import 'package:cliq/shared/provider/store.provider.dart';
import 'package:cliq/shared/ui/error_view.dart';
import 'package:cliq/shared/utils/commons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Router;
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'shared/data/database.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    if (kDebugMode) {
      _initLogger();
    }

    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      _handleError(details.exception, details.stack ?? StackTrace.empty);
    };

    CliqDatabase.init();
    SharedPreferences.setPrefix('cliq.');
    await KeyValueStore.init();

    runApp(const ProviderScope(child: CliqApp()));
  }, _handleError);
}

void _handleError(Object error, StackTrace stackTrace) {
  debugPrint(stackTrace.toString());

  String errorMessage = error.toString();
  if (errorMessage.length > 150) {
    errorMessage = '${errorMessage.substring(0, 150)}...';
  }

  showFToast(
    context: Router.rootNavigatorKey.currentContext!,
    variant: .destructive,
    title: Text(errorMessage),
    suffixBuilder: (context, entry) {
      return FTooltip(
        tipBuilder: (_, _) => Text('View error details'),
        child: GestureDetector(
          onTap: () {
            entry.dismiss();
            Commons.showResponsiveDialog(
              (_) => ErrorView(error: error, stackTrace: stackTrace),
            );
          },
          child: Icon(
            LucideIcons.squareArrowOutUpRight,
            color: context.theme.colors.destructive,
            size: 20,
          ),
        ),
      );
    },
    duration: null,
  );
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
    final theme = useStore(.theme);
    final themeMode = useStore(.themeMode);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      routerConfig: router.goRouter,
      debugShowCheckedModeBanner: false,
      themeMode: themeMode.value,
      theme: ThemeData(brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      builder: (context, child) {
        return FTheme(
          data: theme.value.getThemeWithMode(themeMode.value),
          child: FToaster(child: child ?? Container()),
        );
      },
    );
  }
}
