import 'dart:io';

final class Validators {
  const Validators._();

  static String? chain(
    List<String? Function(Object?)> validators,
    Object? value,
  ) {
    for (final validator in validators) {
      String? error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  static String? address(Object? value) {
    String? nonEmptyError = nonEmpty(value);
    if (nonEmptyError != null) {
      return nonEmptyError;
    }
    if (value is! String) {
      return 'Value must be a valid host string';
    }
    final String input = value;

    if (InternetAddress.tryParse(input) != null) {
      return null;
    }

    final hostnameRegex = RegExp(
      r'^(?=.{1,253}$)(?!-)([A-Za-z0-9-]{1,63}(?<!-)\.)+[A-Za-z]{2,63}$',
    );

    if (hostnameRegex.hasMatch(input)) {
      return null;
    }

    return 'Please provide a valid hostname';
  }

  static String? pem(Object? value) {
    String? nonEmptyError = nonEmpty(value);
    if (nonEmptyError != null) {
      return nonEmptyError;
    }

    final pemRegex = RegExp(
      r'-----BEGIN (RSA|EC|DSA|OPENSSH|ED25519) PRIVATE KEY-----\s+'
      r'([A-Za-z0-9+/=\s]+)'
      r'-----END (RSA|EC|DSA|OPENSSH|ED25519) PRIVATE KEY-----',
      multiLine: true,
    );

    final match = pemRegex.firstMatch(value as String);
    if (match == null) {
      return 'Invalid PEM private key format';
    }

    return null;
  }

  static String? port(Object? value) {
    String? integerError = integer(value);
    if (integerError != null) {
      return integerError;
    }
    int port = int.parse(value as String);
    if (port < 1 || port > 65535) {
      return 'Value is not a valid port';
    }
    return null;
  }

  static String? integer(Object? value) {
    String? nonEmptyError = nonEmpty(value);
    if (nonEmptyError != null) {
      return nonEmptyError;
    }
    if (value is String) {
      int? parsed = int.tryParse(value);
      if (parsed == null) {
        return 'Value is not a valid integer';
      }
    } else if (value! is int) {
      return 'Value is not a valid integer';
    }
    return null;
  }

  static String? hexColor(Object? value) {
    if (value is String) {
      if (value.isEmpty) {
        return null;
      }

      final hexColorRegex = RegExp(r'^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
      if (!hexColorRegex.hasMatch(value)) {
        return 'Value is not a valid hex color';
      }
    } else {
      return 'Value is not a valid hex color';
    }
    return null;
  }

  static String? nonEmpty(Object? value) {
    String? nonNullError = nonNull(value);
    if (nonNullError != null) {
      return nonNullError;
    }
    if (value is String && value.isEmpty) {
      return 'Value may not be empty';
    }
    return null;
  }

  static String? nonNull(Object? value) {
    if (value == null) {
      return 'Value may not be null';
    }
    return null;
  }
}
