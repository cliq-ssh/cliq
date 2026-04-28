import 'package:cliq/modules/keys/model/key_importer/key_importer.dart';

/// Parser for OpenSSH formatted public keys.
/// These keys typically start with "ssh-rsa" or "ssh-ed25519" and are followed by the base64 encoded key data and an
/// optional comment.
class OpenSSHPublicKeyImporter extends AbstractKeyImporter {
  const OpenSSHPublicKeyImporter();

  @override
  KeyImporterType get type => .public;

  @override
  Future<String?> tryParse(String content) async {
    content = content.trim();
    // check if the content starts with a valid OpenSSH public key prefix
    final lines = content.split('\n');

    if (lines.length != 1 || !content.startsWith('ssh-')) {
      return null;
    }

    return content;
  }
}
