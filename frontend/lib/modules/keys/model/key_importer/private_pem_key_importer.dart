import 'package:cliq/modules/keys/model/key_importer/key_importer.dart';

/// Parser for PEM formatted private keys.
class PrivatePemKeyImporter extends AbstractKeyImporter {
  const new();

  @override
  KeyImporterType get type => .private;

  @override
  Future<String?> tryParse(String content) async {
    final effectiveContent = content.trim();
    // check if first line and last line are the expected PEM headers and footers
    final lines = effectiveContent.split('\n');
    if (lines.length < 2 ||
        !lines.first.contains('BEGIN') ||
        !lines.last.contains('END')) {
      return null;
    }

    return effectiveContent;
  }
}
