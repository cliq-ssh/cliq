import 'dart:convert';
import 'dart:typed_data';

import 'package:cliq/shared/data/database.dart';

/// A model representing a known host error encountered during SSH connection.
class const KnownHostError({
  required final String host,
  required final String algorithm,
  required final Uint8List fingerprint,

  /// The known host entry that was found, if any.
  required final KnownHostsCompanion? knownHost,
}) {
  String get fingerprintString => utf8.decode(fingerprint);
}
