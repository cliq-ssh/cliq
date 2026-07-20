import 'dart:async';
import 'dart:convert';

import 'package:cliq/shared/ui/entity_card_view.dart';
import 'package:cliq_api/cliq_api.dart';
import 'package:cliq_term/cliq_term.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/settings/model/keyboard_shortcuts.model.dart';
import '../../modules/settings/model/theme.model.dart';

enum StoreKey<T> {
  syncHost<RouteOptions?>(
    'sync_host',
    type: RouteOptions,
    fromValue: _routeOptionsFromValue,
    toValue: _routeOptionsToValue,
  ),
  syncEmail<String?>('sync_email', type: String, isSecure: true),
  syncDPK<String?>('sync_dpk', type: String, isSecure: true),
  syncDEK<String?>('sync_dek', type: String, isSecure: true),
  syncRefreshToken<String?>('sync_refresh_token', type: String, isSecure: true),

  theme<CliqTheme>(
    'theme',
    type: CliqTheme,
    defaultValue: CliqTheme.zinc,
    fromValue: _themeFromValue,
    toValue: _enumToValue,
  ),
  themeMode<ThemeMode>(
    'theme_mode',
    type: ThemeMode,
    defaultValue: ThemeMode.system,
    fromValue: _themeModeFromValue,
    toValue: _enumToValue,
  ),

  defaultTerminalTypography<TerminalTypography>(
    'default_terminal_typography',
    type: TerminalTypography,
    defaultValue: TerminalTypography(fontFamily: 'SourceCodePro', fontSize: 16),
    fromValue: _typographyFromValue,
    toValue: _typographyToValue,
  ),
  defaultTerminalThemeId<int>(
    'default_terminal_theme',
    type: int,
    defaultValue: -1,
  ),
  applyTerminalThemeColorToNavigation<bool>(
    'apply_terminal_theme_to_navigation',
    type: bool,
    defaultValue: true,
  ),

  knownHostsCardViewType<EntityCardViewType>(
    'known_hosts_card_view_type',
    type: EntityCardViewType,
    defaultValue: .list,
    fromValue: _entityCardViewTypeFromValue,
    toValue: _enumToValue,
  ),
  identitiesCardViewType<EntityCardViewType>(
    'identities_card_view_type',
    type: EntityCardViewType,
    defaultValue: .list,
    fromValue: _entityCardViewTypeFromValue,
    toValue: _enumToValue,
  ),
  connectionsCardViewType<EntityCardViewType>(
    'connections_card_view_type',
    type: EntityCardViewType,
    defaultValue: .list,
    fromValue: _entityCardViewTypeFromValue,
    toValue: _enumToValue,
  ),
  keysCardViewType<EntityCardViewType>(
    'keys_card_view_type',
    type: EntityCardViewType,
    defaultValue: .list,
    fromValue: _entityCardViewTypeFromValue,
    toValue: _enumToValue,
  ),

  shortcuts<KeyboardShortcuts>(
    'shortcuts',
    type: KeyboardShortcutType,
    defaultFactory: _defaultShortcutsFactory,
    fromValue: _shortcutsFromValue,
    toValue: _shortcutsToValue,
  ),

  sshScrollbackSize<int>(
    'ssh_scrollback_size',
    type: int,
    defaultValue: TerminalBuffer.defaultMaxScrollbackLines,
  ),

  sftpShowHiddenFiles<bool>(
    'sftp_show_hidden_files',
    type: bool,
    defaultValue: false,
  ),
  sftpLargeDownloadWarning<bool>(
    'sftp_large_download_warning',
    type: bool,
    defaultValue: true,
  ),
  sftpDirectoryNotEmptyWarning<bool>(
    'sftp_directory_not_empty_warning',
    type: bool,
    defaultValue: true,
  ),

  terminalBellSound<bool>(
    'terminal_bell_sound',
    type: bool,
    defaultValue: true,
  ),
  terminalCursorStyle<CursorStyle>(
    'terminal_cursor_style',
    type: CursorStyle,
    defaultValue: .bar,
    fromValue: _cursorStyleFromValue,
    toValue: _enumToValue,
  ),
  terminalCursorBlinkInterval<int>(
    'terminal_cursor_blink_interval',
    type: int,
    defaultValue: 600,
  ),

  terminalCursorBlinkTimeout<int>(
    'terminal_cursor_blink_timeout',
    type: int,
    defaultValue: 10,
  );

  final String key;
  final Type type;
  final T? defaultValue;
  final T Function()? defaultFactory;
  final T? Function(String?)? fromValue;
  final String? Function(T?)? toValue;
  final bool isSecure;

  const StoreKey(
    this.key, {
    required this.type,
    this.defaultValue,
    this.defaultFactory,
    this.fromValue,
    this.toValue,
    this.isSecure = false,
  }) : assert(defaultValue == null || defaultFactory == null);

  T? readSync() => KeyValueStore._instance.readSync(this);
  String? readAsStringSync() => KeyValueStore._instance.readAsStringSync(this);
  Future<T?> readAsync() => KeyValueStore._instance.readAsync(this);
  Future<String?> readAsStringAsync() =>
      KeyValueStore._instance.readAsStringAsync(this);
  void write(T value) => KeyValueStore._instance.write(this, value);
  FutureOr<void> delete() => KeyValueStore._instance.delete(this);

  // Enums
  static T? _enumFromValue<T extends Enum>(String? value, List<T> values) =>
      value == null
      ? null
      : values.firstWhere((element) => element.name == value);
  static String? _enumToValue<T extends Enum>(dynamic value) =>
      value is T? ? value?.name : null;

  static CliqTheme? _themeFromValue(String? value) =>
      _enumFromValue(value, CliqTheme.values);
  static ThemeMode? _themeModeFromValue(String? value) =>
      _enumFromValue(value, ThemeMode.values);
  static EntityCardViewType? _entityCardViewTypeFromValue(String? value) =>
      _enumFromValue(value, EntityCardViewType.values);
  static CursorStyle? _cursorStyleFromValue(String? value) =>
      _enumFromValue(value, CursorStyle.values);

  static String? _routeOptionsToValue(RouteOptions? value) {
    if (value == null) return null;
    return jsonEncode(value.toJson());
  }

  static RouteOptions? _routeOptionsFromValue(String? value) {
    if (value == null) return null;
    final Map<String, dynamic> json = .from(jsonDecode(value) as Map);
    return RouteOptions.fromJson(json);
  }

  static String? _typographyToValue(TerminalTypography? value) {
    if (value == null) return null;
    return [value.fontSize, value.fontFamily].join(';');
  }

  static TerminalTypography? _typographyFromValue(String? value) {
    if (value == null) return null;
    final parts = value.split(';');
    if (parts.length != 2) return null;
    final fontSize = int.tryParse(parts[0]);
    final fontFamily = parts[1];
    if (fontSize == null) return null;
    return TerminalTypography(fontSize: fontSize, fontFamily: fontFamily);
  }

  static KeyboardShortcuts _defaultShortcutsFactory() =>
      KeyboardShortcuts.platformDefaults;

  static String? _shortcutsToValue(KeyboardShortcuts? shortcuts) =>
      shortcuts != null ? jsonEncode(shortcuts.toJson()) : null;

  static KeyboardShortcuts? _shortcutsFromValue(String? value) => value != null
      ? KeyboardShortcuts.fromJson(.from(jsonDecode(value) as Map))
      : null;
}

/// Small data class representing a change in the store
class StoreChange {
  final String key;
  final dynamic value;

  StoreChange(this.key, {required this.value});
}

/// A simple key-value store that uses SharedPreferences and FlutterSecureStorage to store data.
/// This class is a singleton and should be initialized once before using it. (See [init])
/// The store uses a local cache to allow synchronous reads, making it easier to use
/// in the UI layer.
class KeyValueStore {
  static final KeyValueStore _instance = KeyValueStore._();

  static final Map<String, dynamic> _localCache = {};

  late final SharedPreferences _preferences;
  late final FlutterSecureStorage _secureStorage;
  bool _initialized = false;

  factory KeyValueStore() => _instance;

  final StreamController<StoreChange> _changesController = .broadcast();
  Stream<StoreChange> get changes => _changesController.stream;

  KeyValueStore._();

  /// Initializes the KeyValueStore by loading the SharedPreferences and FlutterSecureStorage.
  /// This will also initialize all default values for the keys & populate the local cache.
  /// This method should only be called once - Otherwise, it will throw a StateError.
  static Future<void> init() async {
    if (_instance._initialized) {
      throw StateError('Store has already been initialized!');
    }
    _instance._preferences = await SharedPreferences.getInstance();
    _instance._secureStorage = const FlutterSecureStorage(
      mOptions: MacOsOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
        usesDataProtectionKeychain: false,
      ),
    );
    _instance._initialized = true;
    for (StoreKey key in StoreKey.values) {
      // initializes all default values for keys that do not exist &
      // populate local cache
      if (key.isSecure) continue;
      _localCache[key.key] = await key.readAsync();
    }
  }

  /// A stream of all changes made to the store.
  Stream<T> streamForKey<T>(StoreKey<T> key) async* {
    _checkInitialized();
    // yield current cached value first
    yield readSync<T>(key);

    // yield updates
    await for (final StoreChange change in changes) {
      if (change.key == key.key) {
        yield change.value ?? (key.defaultValue ?? key.defaultFactory!.call())!;
      }
    }
  }

  /// Reads the value of the key from the local cache.
  /// If the key does not exist in the cache, it will return null.
  T readSync<T>(StoreKey<T> key) {
    if (key.isSecure) {
      throw StateError(
        'Cannot read secure key ${key.key} from cache! Use readAsync() instead.',
      );
    }

    _checkInitialized();
    return _fromStringOrValue<T>(_localCache[key.key], key);
  }

  /// Reads the value of the key from the local cache and converts it to a string,
  /// by either using the [toValue] function of the key or by simply returning
  /// its toString() representation.
  String? readAsStringSync<T>(StoreKey<T> key) {
    return _toStringOrValue<T?>(readSync(key), key).toString();
  }

  /// Reads the value of the key from the local cache.
  /// If the key does not exist in the cache, it will be read from the storage.
  Future<T?> readAsync<T>(StoreKey<T> key) async {
    _checkInitialized();

    if (key.isSecure) {
      return await _readOrInitSecureStorageKey(key);
    } else {
      return await _readOrInitSharedPrefsKey(key);
    }
  }

  /// Reads the value of the key from the local cache and converts it to a string,
  /// by either using the [toValue] function of the key or by simply returning
  /// its toString() representation.
  Future<String?> readAsStringAsync<T>(StoreKey<T> key) async {
    return _toStringOrValue<T?>(await readAsync(key), key);
  }

  /// Writes the value to the local cache and the storage.
  Future<void> write<T>(
    StoreKey<T> key,
    T value, {
    bool storeLocal = true,
    bool triggerChange = true,
  }) async {
    _checkInitialized();
    // simplify enums to strings
    if (!key.isSecure && storeLocal) {
      _localCache[key.key] = value;
    }
    if (!key.isSecure && triggerChange) {
      _changesController.add(StoreChange(key.key, value: value));
    }
    if (value is Enum) {
      return await write(
        key,
        value.name,
        storeLocal: false,
        triggerChange: false,
      );
    }
    final dynamic effectiveValue = _toStringOrValue<T?>(value, key);

    if (key.isSecure) {
      await _secureStorage.write(
        key: key.key,
        value: effectiveValue.toString(),
      );
    } else {
      await switch (effectiveValue) {
        (String value) => _preferences.setString(key.key, value),
        (int value) => _preferences.setInt(key.key, value),
        (bool value) => _preferences.setBool(key.key, value),
        (double value) => _preferences.setDouble(key.key, value),
        _ => throw StateError(
          'Invalid value for key ${key.key}! Got: ${effectiveValue.runtimeType}, Expected either String, int, bool or double',
        ),
      };
    }
  }

  /// Deletes the key from the local cache and the storage.
  /// If the key has a default value, it will be reset to that value instead.
  FutureOr<void> delete<T>(StoreKey<T> key) {
    _checkInitialized();
    if (key.defaultValue == null) {
      if (key.isSecure) {
        _secureStorage.delete(key: key.key);
      } else {
        _localCache.remove(key.key);
        _preferences.remove(key.key);
        _changesController.add(StoreChange(key.key, value: null));
      }
    } else {
      write(key, key.defaultValue);
    }
  }

  FutureOr<T>? _readOrInitSharedPrefsKey<T>(StoreKey<T> key) {
    if (_preferences.containsKey(key.key)) {
      final dynamic value = _preferences.get(key.key);
      return _fromStringOrValue(value, key);
    }
    final T? defaultValue = _getDefault(key);
    if (defaultValue == null) {
      return null;
    }
    return write(key, defaultValue).then((_) => defaultValue);
  }

  Future<T?> _readOrInitSecureStorageKey<T>(StoreKey<T> key) async {
    final String? value = await _secureStorage.read(key: key.key);
    if (value != null) {
      return _fromStringOrValue(value, key);
    }
    final T? defaultValue = _getDefault(key);
    if (defaultValue == null) {
      return null;
    }
    await write(key, defaultValue);
    return defaultValue;
  }

  void _checkInitialized() {
    if (!_initialized) {
      throw StateError('Store has not been initialized yet!');
    }
  }

  /// Returns the default value of the key.
  T? _getDefault<T>(StoreKey<T> key) {
    if (key.defaultFactory != null) {
      return key.defaultFactory!();
    }
    return key.defaultValue;
  }

  static dynamic _toStringOrValue<T>(T value, StoreKey<T> key) {
    final dynamic d = key.toValue?.call(value) ?? value;
    if (d is Enum) {
      return d.name;
    }
    return d;
  }

  static T _fromStringOrValue<T>(dynamic value, StoreKey<T> key) {
    if (value is T) {
      return value;
    }
    return (key.fromValue?.call(value) ??
            key.defaultValue ??
            key.defaultFactory?.call())
        as T;
  }
}
