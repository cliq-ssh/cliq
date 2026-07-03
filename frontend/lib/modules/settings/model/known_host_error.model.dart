import 'dart:convert';
import 'dart:typed_data';

import '../../../shared/data/database.dart';

class KnownHostError {
  final String host;
  final String algorithm;
  final Uint8List fingerprint;
  // The known host entry that was found, if any.
  final KnownHostsCompanion? knownHost;

  const KnownHostError({
    required this.host,
    required this.algorithm,
    required this.fingerprint,
    this.knownHost,
  });

  String get fingerprintString => utf8.decode(fingerprint);
}
