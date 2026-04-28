import 'package:cliq/modules/keys/model/key_importer/private_pem_key_importer.dart';
import 'package:cliq/modules/keys/model/key_importer/public_key_importer.dart';

enum KeyImporterType { private, public }

enum KeyImporter {
  privatePem(PrivatePemKeyImporter()),
  publicPem(OpenSSHPublicKeyImporter());

  final AbstractKeyImporter instance;

  const KeyImporter(this.instance);

  /// Attempts to parse the given content using all available key importers.
  /// Returns the first successful parse result, or null if none of the importers could parse the content.
  static Future<String?> parse(
    String? content, {
    KeyImporterType? filter,
  }) async {
    if (content == null) return null;

    for (final parser in KeyImporter.values) {
      if (filter != null && parser.instance.type != filter) {
        continue;
      }
      final parsed = await parser.instance.tryParse(content);
      if (parsed != null) {
        return parsed;
      }
    }
    return null;
  }
}

abstract class AbstractKeyImporter {
  const AbstractKeyImporter();

  KeyImporterType get type;

  /// Attempts to parse a PEM formatted private key from the given content.
  Future<String?> tryParse(String content);
}
