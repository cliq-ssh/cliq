import 'dart:typed_data';

import '../../../shared/data/database.dart';

class KnownHostError {
  final String host;
  final Uint8List hostKey;
  final String algorithm;
  final String sha256Fingerprint;
  // The known host entry that was found, if any.
  final KnownHostsCompanion? knownHost;

  const KnownHostError({
    required this.host,
    required this.hostKey,
    required this.algorithm,
    required this.sha256Fingerprint,
    this.knownHost,
  });
}
