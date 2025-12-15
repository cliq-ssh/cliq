import 'dart:async';

import 'package:cliq_term/cliq_term.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../modules/settings/model/theme.model.dart';

enum StoreKey<T> {
  userName<String>('user_name', type: String),
  hostUrl<String>('host_url', type: String),
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

  terminalTypography<TerminalTypography>(
    'terminal_typography',
    type: TerminalTypography,
    fromValue: _typographyFromValue,
    toValue: _typographyToValue,
  ),
  terminalTheme<TerminalColorTheme>(
    'terminal_color_theme',
    type: TerminalColorTheme,
    fromValue: _terminalColorsFromValue,
    toValue: _terminalColorsToValue,
  );

  final String key;
  final Type type;
  final T? defaultValue;
  final T Function()? defaultFactory;
  final T? Function(String?)? fromValue;
  final String? Function(T?)? toValue;

  const StoreKey(
    this.key, {
    required this.type,
    this.defaultValue,
    this.defaultFactory,
    this.fromValue,
    this.toValue,
  }) : assert(defaultValue == null || defaultFactory == null);

  T? readSync() => KeyValueStore._instance.readSync(this);
  String? readAsStringSync() => KeyValueStore._instance.readAsStringSync(this);
  Future<T?> readAsync() => KeyValueStore._instance.readAsync(this);
  Future<String?> readAsStringAsync() =>
      KeyValueStore._instance.readAsStringAsync(this);
  void write(T value) => KeyValueStore._instance.write(this, value);
  Future<void> delete() => KeyValueStore._instance.delete(this);

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

  // save smicolon-separated typography values
  static String? _typographyToValue(TerminalTypography? value) {
    if (value == null) return null;
    return [value.fontFamily, value.fontSize.toString()].join(';');
  }

  static String? _terminalColorsToValue(TerminalColorTheme? value) {
    if (value == null) return null;
    return [
      value.cursorColor,
      value.selectionColor,
      value.backgroundColor,
      value.foregroundColor,
      value.selectionColor,
      value.black,
      value.red,
      value.green,
      value.yellow,
      value.blue,
      value.magenta,
      value.cyan,
      value.white,
      value.brightBlack,
      value.brightRed,
      value.brightGreen,
      value.brightYellow,
      value.brightBlue,
      value.brightMagenta,
      value.brightCyan,
      value.brightWhite,
    ].join(';');
  }

  static TerminalTypography? _typographyFromValue(String? value) {
    if (value == null) return null;
    final parts = value.split(';');
    if (parts.length != 2) return null;
    final fontFamily = parts[0];
    final fontSize = double.tryParse(parts[1]);
    if (fontSize == null) return null;
    return TerminalTypography(fontFamily: fontFamily, fontSize: fontSize);
  }

  static TerminalColorTheme? _terminalColorsFromValue(String? value) {
    if (value == null) return null;
    final parts = value.split(';');
    if (parts.length != 18) return null;
    Color parseColor(String str) {
      final intValue = int.tryParse(str);
      if (intValue == null) {
        throw FormatException('Invalid color value: $str');
      }
      return Color(intValue);
    }

    return TerminalColorTheme(
      cursorColor: parseColor(parts[0]),
      selectionColor: parseColor(parts[1]),
      backgroundColor: parseColor(parts[2]),
      foregroundColor: parseColor(parts[3]),
      black: parseColor(parts[5]),
      red: parseColor(parts[6]),
      green: parseColor(parts[7]),
      yellow: parseColor(parts[8]),
      blue: parseColor(parts[9]),
      magenta: parseColor(parts[10]),
      cyan: parseColor(parts[11]),
      white: parseColor(parts[12]),
      brightBlack: parseColor(parts[13]),
      brightRed: parseColor(parts[14]),
      brightGreen: parseColor(parts[15]),
      brightYellow: parseColor(parts[16]),
      brightBlue: parseColor(parts[17]),
      brightMagenta: parseColor(parts[18]),
      brightCyan: parseColor(parts[19]),
      brightWhite: parseColor(parts[20]),
    );
  }
}

/// A simple key-value store that uses SharedPreferences and FlutterSecureStorage to store data.
/// This class is a singleton and should be initialized once before using it. (See [init])
/// The store uses a local cache to allow synchronous reads, making it easier to use
/// in the UI layer.
class KeyValueStore {
  static final KeyValueStore _instance = KeyValueStore._();
  static final Map<String, dynamic> _localCache = {};

  late final SharedPreferences _preferences;
  bool _initialized = false;

  factory KeyValueStore() => _instance;

  KeyValueStore._();

  /// Initializes the KeyValueStore by loading the SharedPreferences and FlutterSecureStorage.
  /// This will also initialize all default values for the keys & populate the local cache.
  /// This method should only be called once - Otherwise, it will throw a StateError.
  static Future<void> init() async {
    if (_instance._initialized) {
      throw StateError('Store has already been initialized!');
    }
    _instance._preferences = await SharedPreferences.getInstance();
    _instance._initialized = true;
    for (StoreKey key in StoreKey.values) {
      // initializes all default values for keys that do not exist &
      // populate local cache
      _localCache[key.key] = await key.readAsync();
    }
  }

  /// Reads the value of the key from the local cache.
  /// If the key does not exist in the cache, it will return null.
  T? readSync<T>(StoreKey<T> key) {
    _checkInitialized();
    return _localCache[key.key];
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
    return await _readOrInitSharedPrefsKey(key);
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
  }) async {
    _checkInitialized();
    // simplify enums to strings
    if (storeLocal) {
      _localCache[key.key] = value;
    }
    if (value is Enum) {
      return await write(key, value.name, storeLocal: false);
    }
    final dynamic effectiveValue = _toStringOrValue<T?>(value, key);
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

  /// Deletes the key from the local cache and the storage.
  Future<void> delete<T>(StoreKey<T> key) async {
    _checkInitialized();
    _localCache.remove(key.key);
    _preferences.remove(key.key);
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

  static T? _fromStringOrValue<T>(dynamic value, StoreKey<T> key) {
    return key.fromValue?.call(value) ?? value as T?;
  }
}
