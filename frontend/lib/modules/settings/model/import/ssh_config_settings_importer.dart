import 'dart:io';

import 'package:cliq/modules/settings/model/import/settings_import.dart';
import 'package:cliq/modules/settings/model/import/settings_importer.dart';

enum OpenSSHConfigOption { include, host, hostName, identityFile, port, user }

/// Parser for the OpenSSH config file format, typically found at ~/.ssh/config.
/// https://www.ssh.com/academy/ssh/config
class SSHConfigSettingsImporter extends AbstractSettingsImporter {
  const SSHConfigSettingsImporter();

  @override
  bool canParse(File file) {
    // check if file has Include or Host directives
    try {
      final content = file.readAsStringSync();
      return content.contains(RegExp(r'^\s*(Include|Host)\b', multiLine: true));
    } catch (e) {
      return false;
    }
  }

  @override
  SettingsImport? tryParse(File file) {
    final content = _resolveTotalContentFromIncludes(file);

    final Map<String, List<(OpenSSHConfigOption, Iterable<String>)>> hosts = {};
    String? currentHost;

    for (final line in content.split('\n')) {
      final option = _readOptionByLine(line);
      if (option == null) {
        continue;
      }

      if (option.$1 == OpenSSHConfigOption.host) {
        currentHost = option.$2.join(' ').trim();
        hosts[currentHost] = [];
      } else if (currentHost != null) {
        hosts[currentHost]!.add(option);
      }
    }

    print(hosts);

    // TODO:
    return null;
  }

  /// Recursively resolves the content of the config file, including any files specified by Include directives.
  String _resolveTotalContentFromIncludes(File file) {
    final StringBuffer totalContent = StringBuffer();
    final lines = file.readAsLinesSync();

    for (final line in lines) {
      final option = _readOptionByLine(line);
      if (option != null && option.$1 == OpenSSHConfigOption.include) {
        // resolve included file and add its content to totalContent
        final includedFilePath = option.$2.join(' ').trim();
        final includedFile = File(includedFilePath);

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

  (OpenSSHConfigOption, Iterable<String>)? _readOptionByLine(String line) {
    final split = line.split(' ');
    for (OpenSSHConfigOption o in OpenSSHConfigOption.values) {
      if (split.first.toLowerCase() == o.name.toLowerCase()) {
        return (o, split.skip(1));
      }
    }
    return null;
  }
}
