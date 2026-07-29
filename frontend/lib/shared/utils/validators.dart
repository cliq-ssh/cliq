import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

final class Validators {
  const Validators._();

  static String? chain(
    BuildContext context,
    List<String? Function(BuildContext, Object?)> validators,
    Object? value,
  ) {
    for (final validator in validators) {
      String? error = validator(context, value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  static String? address(BuildContext context, Object? value) {
    String? nonEmptyError = nonEmpty(context, value);
    if (nonEmptyError != null) {
      return nonEmptyError;
    }
    if (value is! String) {
      return 'validator_error_invalid_address'.tr(context: context);
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

    return 'validator_error_invalid_address'.tr(context: context);
  }

  static String? username(BuildContext context, Object? value) {
    String? nonEmptyError = nonEmpty(context, value);
    if (nonEmptyError != null) {
      return nonEmptyError;
    }
    if (value is! String) {
      return 'validator_error_invalid_username'.tr(context: context);
    }
    final String input = value;

    final usernameRegex = RegExp(r'^[a-zA-Z0-9._-]{3,20}$');

    if (!usernameRegex.hasMatch(input)) {
      return 'validator_error_invalid_username'.tr(context: context);
    }

    return null;
  }

  static String? email(BuildContext context, Object? value) {
    String? nonEmptyError = nonEmpty(context, value);
    if (nonEmptyError != null) {
      return nonEmptyError;
    }
    if (value is! String) {
      return 'validator_error_invalid_email'.tr(context: context);
    }
    final String input = value;

    final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    if (!emailRegex.hasMatch(input)) {
      return 'validator_error_invalid_email'.tr(context: context);
    }

    return null;
  }

  static String? passwordConfirm(
    BuildContext context,
    Object? value,
    String? password,
  ) {
    String? nonEmptyError = nonEmpty(context, value);
    if (nonEmptyError != null) {
      return nonEmptyError;
    }
    if (value is! String) {
      return 'validator_error_invalid_password_confirm'.tr(context: context);
    }
    final String input = value;

    if (input != password) {
      return 'validator_error_invalid_password_confirm'.tr(context: context);
    }

    return null;
  }

  static String? syncServerUrl(BuildContext context, Object? value) {
    String? nonEmptyError = nonEmpty(context, value);
    if (nonEmptyError != null) {
      return nonEmptyError;
    }
    if (value is! String) {
      return 'validator_error_invalid_sync_server_url'.tr(context: context);
    }
    final String input = value;

    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      return 'validator_error_invalid_sync_server_url_missing_schema'.tr(
        context: context,
      );
    }

    return null;
  }

  static String? pem(BuildContext context, Object? value) {
    String? nonEmptyError = nonEmpty(context, value);
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
      return 'validator_error_invalid_pem_private_key'.tr(context: context);
    }

    return null;
  }

  static String? port(BuildContext context, Object? value) {
    String? integerError = integer(context, value);
    if (integerError != null) {
      return integerError;
    }
    int port = int.parse(value as String);
    if (port < 1 || port > 65535) {
      return 'validator_error_invalid_port'.tr(context: context);
    }
    return null;
  }

  static String? integer(BuildContext context, Object? value) {
    String? nonEmptyError = nonEmpty(context, value);
    if (nonEmptyError != null) {
      return nonEmptyError;
    }
    if (value is String) {
      int? parsed = int.tryParse(value);
      if (parsed == null) {
        return 'validator_error_invalid_integer'.tr(context: context);
      }
    } else if (value! is int) {
      return 'validator_error_invalid_integer'.tr(context: context);
    }
    return null;
  }

  static String? hexColor(BuildContext context, Object? value) {
    if (value is String) {
      if (value.isEmpty) {
        return null;
      }

      final hexColorRegex = RegExp(r'^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$');
      if (!hexColorRegex.hasMatch(value)) {
        return 'validator_error_invalid_hex_color'.tr(context: context);
      }
    } else {
      return 'validator_error_invalid_hex_color'.tr(context: context);
    }
    return null;
  }

  static String? nonEmpty(BuildContext context, Object? value) {
    String? nonNullError = nonNull(context, value);
    if (nonNullError != null) {
      return nonNullError;
    }
    if (value is String && value.isEmpty) {
      return 'validator_error_empty'.tr(context: context);
    }
    return null;
  }

  static String? nonNull(BuildContext context, Object? value) {
    if (value == null) {
      return 'validator_error_null'.tr(context: context);
    }
    return null;
  }
}
