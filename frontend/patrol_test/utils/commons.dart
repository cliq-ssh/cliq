import 'package:cliq/main.dart';
import 'package:cliq/shared/data/store.dart';
import 'package:cliq/shared/utils/constants.dart';
import 'package:cliq/shared/utils/password_cipher.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:patrol/patrol.dart';
import 'package:shared_preferences/shared_preferences.dart';

export 'package:flutter_test/flutter_test.dart';
export 'package:patrol/patrol.dart';

const _patrolTesterConfig = PatrolTesterConfig(printLogs: true);

/// Creates the app for testing with [PatrolIntegrationTester].
/// This mirrors what is done in `main.dart`, but without awaiting initialisation,
/// window configuration, error handling like described in the Patrol docs:
/// https://patrol.leancode.co/documentation#initializing-app-inside-a-test
Future<void> patrolCreateApp(PatrolIntegrationTester $) async {
  SharedPreferences.setPrefix('cliq.');
  await EasyLocalization.ensureInitialized();
  await KeyValueStore.init();
  await PasswordCipher.init();

  await $.pumpWidgetAndSettle(
    EasyLocalization(
      path: 'assets/translations',
      supportedLocales: Constants.supportedLocales.values.toList(),
      fallbackLocale: Constants.supportedLocales.values.first,
      child: const ProviderScope(child: CliqApp()),
    ),
  );
}

/// Wrapper for [patrolTest] with default config for the app.
void patrol(
  String description,
  Future<void> Function(PatrolIntegrationTester) callback, {
  bool? skip,
  List<String> tags = const [],
}) {
  patrolTest(
    description,
    config: _patrolTesterConfig,
    skip: skip,
    callback,
    tags: tags,
  );
}
