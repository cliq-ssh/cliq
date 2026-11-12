import 'dart:async';
import 'dart:convert';

import 'package:cliq/modules/settings/model/app_theme/app_theme.model.dart';
import 'package:cliq/modules/settings/model/keyboard_shortcuts.model.dart';
import 'package:cliq/modules/settings/model/terminal_typography.model.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:cliq/shared/ui/entity_card_view.dart';
import 'package:cliq_api/cliq_api.dart';
import 'package:flterm/flterm.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const int defaultSshScrollbackSize = 2000;
const CursorTheme defaultCursorTheme = .new();

enum StoreKey<T> {
  developerMode<bool>('developer_mode', type: bool, defaultValue: kDebugMode),

  syncHost<RouteOptions?>(
    'sync_host',
    type: RouteOptions,
    fromValue: _routeOptionsFromValue,
    toValue: _routeOptionsToValue,
  ),
  syncDevicePrivateKey<String?>('sync_dpk', type: String, isSecure: true),
  syncDataEncryptionKey<String?>('sync_dek', type: String, isSecure: true),
  syncRefreshToken<String?>('sync_refresh_token', type: String, isSecure: true),

  appearanceBaseColors<PresetBaseColors>(
    'appearance_base_colors',
    type: PresetBaseColors,
    defaultValue: .neutral,
    fromValue: _themeFromValue,
    toValue: _enumToValue,
  ),
  appearancePrimaryColor<PresetPrimaryColor>(
    'appearance_primary_color',
    type: PresetPrimaryColor,
    defaultValue: .neutral,
    fromValue: _primaryColorFromValue,
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
  defaultTerminalThemeId<DbId>(
    'default_terminal_theme',
    type: int,
    defaultValue: '-1',
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

  sshScrollbackSize<int>('ssh_scrollback_size', type: int, defaultValue: 2000),

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
  terminalCursorStyle<CursorTheme>(
    'terminal_cursor_style',
    type: CursorTheme,
    defaultValue: defaultCursorTheme,
    fromValue: _cursorThemeFromValue,
    toValue: _cursorThemeToValue,
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

  new(
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

  static PresetBaseColors? _themeFromValue(String? value) =>
      _enumFromValue(value, PresetBaseColors.values);
  static PresetPrimaryColor? _primaryColorFromValue(String? value) =>
      _enumFromValue(value, PresetPrimaryColor.values);
  static ThemeMode? _themeModeFromValue(String? value) =>
      _enumFromValue(value, ThemeMode.values);
  static EntityCardViewType? _entityCardViewTypeFromValue(String? value) =>
      _enumFromValue(value, EntityCardViewType.values);

  static String? _cursorThemeToValue(CursorTheme? value) {
    // TODO: implement
    return null;
  }

  static CursorTheme? _cursorThemeFromValue(String? value) {
    // TODO: implement
    return null;
  }

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
    return _listToValue([value.fontSize, value.fontFamily]);
  }

  static TerminalTypography? _typographyFromValue(String? value) {
    final List<dynamic>? list = _listFromValue(value);
    if (list == null || list.length != 2) return null;
    final int? fontSize = list[0] as int?;
    final String? fontFamily = list[1] as String?;
    if (fontSize == null || fontFamily == null) return null;
    return TerminalTypography(fontFamily: fontFamily, fontSize: fontSize);
  }

  static KeyboardShortcuts _defaultShortcutsFactory() =>
      KeyboardShortcuts.platformDefaults;

  static String? _shortcutsToValue(KeyboardShortcuts? shortcuts) =>
      shortcuts != null ? jsonEncode(shortcuts.toJson()) : null;

  static KeyboardShortcuts? _shortcutsFromValue(String? value) => value != null
      ? KeyboardShortcuts.fromJson(.from(jsonDecode(value) as Map))
      : null;

  static String? _listToValue<T>(List<T>? list) =>
      list != null ? jsonEncode(list) : null;

  static List<T>? _listFromValue<T>(String? value) {
    List<T>? list;
    try {
      list = value != null ? .from(jsonDecode(value) as List) : null;
    } catch (e) {
      debugPrint('Failed to decode list from value: $value');
    }
    return list;
  }
}

/// Small data class representing a change in the store
class StoreChange {
  final String key;
  final dynamic value;

  new(this.key, {required this.value});
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

  factory() => _instance;

  final StreamController<StoreChange> _changesController = .broadcast();
  Stream<StoreChange> get changes => _changesController.stream;

  new _();

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
        (final String value) => _preferences.setString(key.key, value),
        (final int value) => _preferences.setInt(key.key, value),
        (final bool value) => _preferences.setBool(key.key, value),
        (final double value) => _preferences.setDouble(key.key, value),
        _ => throw StateError(
          'Invalid value for key ${key.key}! Got: ${effectiveValue.runtimeType}, Expected either String, int, bool or double',
        ),
      };
    }
  }

  /// Deletes the key from the local cache and the storage.
  /// If the key has a default value, it will be reset to that value instead.
  Future<void> delete<T>(StoreKey<T> key) async {
    _checkInitialized();
    if (key.defaultValue == null) {
      if (key.isSecure) {
        await _secureStorage.delete(key: key.key);
      } else {
        _localCache.remove(key.key);
        await _preferences.remove(key.key);
        _changesController.add(StoreChange(key.key, value: null));
      }
    } else {
      await write(key, key.defaultValue);
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
