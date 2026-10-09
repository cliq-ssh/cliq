// We need to import these internal utilities to encrypt the private key in the OpenSSH format.
// The Rust bridge owns the OpenSSH key encryption implementation.

import 'package:cliq/src/rust/api/key_generator.dart';
import 'package:cliq/src/rust/ssh/key_generator.dart';

/// SSH key algorithms supported by the key generator UI.
enum SshKeyAlgorithm {
  ed25519,
  ecdsa,
  rsa;

  String get label => switch (this) {
    .ed25519 => 'ED25519',
    .ecdsa => 'ECDSA',
    .rsa => 'RSA',
  };

  String get note => switch (this) {
    .ed25519 => 'OpenSSH 6.5+',
    .ecdsa => 'OpenSSH 5.7+',
    .rsa => 'Legacy Devices',
  };

  String get sshType => switch (this) {
    .ed25519 => 'ssh-ed25519',
    .ecdsa => 'ecdsa-sha2-${SshEcdsaCurveSize.bits256.curveId}',
    .rsa => 'ssh-rsa',
  };

  bool get hasExtraConfig => this != .ed25519;
}

enum SshEcdsaCurveSize {
  bits521,
  bits384,
  bits256;

  int get bits => switch (this) {
    .bits521 => 521,
    .bits384 => 384,
    .bits256 => 256,
  };

  String get label => '$bits bits';

  String get curveId => switch (this) {
    .bits521 => 'nistp521',
    .bits384 => 'nistp384',
    .bits256 => 'nistp256',
  };

  EcdsaBits get ecdsaBits => switch (this) {
    .bits521 => .bits521,
    .bits384 => .bits384,
    .bits256 => .bits256,
  };
}

enum SshRsaKeySize {
  bits4096,
  bits2048;

  int get bits => switch (this) {
    .bits4096 => 4096,
    .bits2048 => 2048,
  };

  String get label => '$bits bits';

  RsaBits get rsaBits => switch (this) {
    .bits4096 => .bits4096,
    .bits2048 => .bits2048,
  };
}

class GeneratedSshKeyPair {
  final String privateKey;
  final String publicKey;

  const new({required this.privateKey, required this.publicKey});
}

/// Generates SSH key pairs in a format supported by the Rust SSH backend.
final class SshKeyGenerator {
  const new _();

  static Future<GeneratedSshKey> generate(
    SshKeyAlgorithm algorithm, {
    SshEcdsaCurveSize ecdsaCurveSize = SshEcdsaCurveSize.bits256,
    SshRsaKeySize rsaKeySize = SshRsaKeySize.bits2048,
    String comment = '',
    String? passphrase,
  }) async {
    return switch (algorithm) {
      SshKeyAlgorithm.ed25519 => await generateSshKey(
        keyType: const SshKeyType.ed25519(),
        comment: comment,
        passphrase: passphrase,
      ),
      SshKeyAlgorithm.ecdsa => await generateSshKey(
        keyType: SshKeyType.ecdsa(ecdsaCurveSize.ecdsaBits),
        comment: comment,
        passphrase: passphrase,
      ),
      SshKeyAlgorithm.rsa => await generateSshKey(
        keyType: SshKeyType.rsa(rsaKeySize.rsaBits),
        comment: comment,
        passphrase: passphrase,
      ),
    };
  }
}
