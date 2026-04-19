import 'dart:io';

import 'package:cliq/modules/settings/model/settings_importer/settings_importer.dart';
import 'package:cliq/shared/data/database.dart';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import 'app_settings.model.dart';

enum OpenSSHConfigOption { include, host, hostName, identityFile, port, user }

/// Parser for the OpenSSH config file format, typically found at ~/.ssh/config.
/// https://www.ssh.com/academy/ssh/config
class SSHConfigSettingsImporter extends AbstractSettingsImporter {
  const SSHConfigSettingsImporter();

  @override
  bool canParse(String path, String content, {String? password}) {
    // check if file has Include or Host directives
    try {
      return content.contains(RegExp(r'^\s*(Include|Host)\b', multiLine: true));
    } catch (e) {
      return false;
    }
  }

  @override
  AppSettings? tryParse(String path, String content, {String? password}) {
    final file = File(path);
    final content = _resolveTotalContentFromIncludes(file);

    final Map<String, Map<OpenSSHConfigOption, Iterable<String>>> hosts = {};
    String? currentHost;

    for (final line in content.split('\n')) {
      final option = _readOptionByLine(line);
      if (option == null) {
        continue;
      }

      if (option.key == OpenSSHConfigOption.host) {
        currentHost = option.value.join(' ').trim();
        hosts[currentHost] = {};
      } else if (currentHost != null) {
        hosts[currentHost]!.putIfAbsent(option.key, () => option.value);
      }
    }

    // Apply wildcard '*' options to all hosts
    if (hosts.containsKey('*')) {
      final wildcardOptions = hosts['*']!;
      for (final host in hosts.keys) {
        if (host != '*') {
          hosts[host]!.addAll(wildcardOptions);
        }
      }
      hosts.remove('*');
    }

    return AppSettings(
      connections: _parseConnections(hosts),
      credentials: [],
      keys: [], // TODO: implement keys & credentials parsing
      identities: [],
      knownHosts: [],
    );
  }

  /// Recursively resolves the content of the config file, including any files specified by Include directives.
  String _resolveTotalContentFromIncludes(File file) {
    final StringBuffer totalContent = StringBuffer();
    final lines = file.readAsLinesSync();

    for (final line in lines) {
      final option = _readOptionByLine(line);
      if (option != null && option.key == OpenSSHConfigOption.include) {
        final includedFilePath = option.value.join(' ').trim();
        // included file path is relative to the current file
        final includedFile = File(
          file.parent.path + Platform.pathSeparator + includedFilePath,
        );
        if (includedFile.existsSync()) {
          totalContent.writeln(_resolveTotalContentFromIncludes(includedFile));
        } else {
          throw StateError('Include file not found: $includedFilePath');
        }
      } else {
        totalContent.writeln(line);
      }
    }

    return totalContent.toString();
  }

  List<ConnectionsCompanion> _parseConnections(
    Map<String, Map<OpenSSHConfigOption, Iterable<String>>> hosts,
  ) {
    final List<ConnectionsCompanion> connections = [];

    for (final host in hosts.keys) {
      final options = hosts[host]!;
      final hostName = options[OpenSSHConfigOption.hostName]?.first ?? host;
      final port =
          int.tryParse(options[OpenSSHConfigOption.port]?.first ?? '') ?? 22;
      final username = options[OpenSSHConfigOption.user]?.first ?? '';

      connections.add(
        ConnectionsCompanion(
          label: Value(hostName),
          address: Value(hostName),
          port: Value(port),
          username: Value(username),
          iconBackgroundColor: Value(Colors.white),
          iconColor: Value(Colors.black),
        ),
      );
    }

    return connections;
  }

  MapEntry<OpenSSHConfigOption, Iterable<String>>? _readOptionByLine(
    String line,
  ) {
    final split = line.trim().split(' ');
    for (OpenSSHConfigOption o in OpenSSHConfigOption.values) {
      if (split.first.toLowerCase() == o.name.toLowerCase()) {
        return MapEntry(o, split.skip(1));
      }
    }
    return null;
  }
}
