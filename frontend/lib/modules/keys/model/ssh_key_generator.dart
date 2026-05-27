import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

// We need to import these internal utilities to encrypt the private key in the OpenSSH format.
// DartSSH2 doesn't provide a public API for this.

import 'package:dartssh2/dartssh2.dart';
// ignore: implementation_imports
import 'package:dartssh2/src/utils/bcrypt.dart';
// ignore: implementation_imports
import 'package:dartssh2/src/utils/cipher_ext.dart';
import 'package:pointycastle/export.dart';
import 'package:sodium/sodium_sumo.dart';

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
}

enum SshRsaKeySize {
  bits4096,
  bits2048,
  bits1024;

  int get bits => switch (this) {
    .bits4096 => 4096,
    .bits2048 => 2048,
    .bits1024 => 1024,
  };

  String get label => '$bits bits';
}

class GeneratedSshKeyPair {
  final String privateKey;
  final String publicKey;

  const GeneratedSshKeyPair({
    required this.privateKey,
    required this.publicKey,
  });
}

/// Generates SSH key pairs in a format that [SSHKeyPair.fromPem] can parse.
final class SshKeyGenerator {
  static SodiumSumo? _sodium;
  static final Random _secureRandom = Random.secure();

  const SshKeyGenerator._();

  static Future<GeneratedSshKeyPair> generate(
    SshKeyAlgorithm algorithm, {
    SshEcdsaCurveSize ecdsaCurveSize = SshEcdsaCurveSize.bits256,
    SshRsaKeySize rsaKeySize = SshRsaKeySize.bits2048,
    String comment = '',
    String? passphrase,
  }) async {
    return switch (algorithm) {
      SshKeyAlgorithm.ed25519 => await _generateEd25519(
        comment,
        passphrase: passphrase,
      ),
      SshKeyAlgorithm.ecdsa => _generateEcdsa(
        comment: comment,
        curveSize: ecdsaCurveSize,
        passphrase: passphrase,
      ),
      SshKeyAlgorithm.rsa => _generateRsa(
        comment: comment,
        bitStrength: rsaKeySize.bits,
        passphrase: passphrase,
      ),
    };
  }

  static Future<GeneratedSshKeyPair> _generateEd25519(
    String comment, {
    String? passphrase,
  }) async {
    final sodium = await _getSodium();
    final keyPair = sodium.crypto.sign.keyPair();

    try {
      final publicKey = Uint8List.fromList(keyPair.publicKey);
      final secretKey = keyPair.secretKey.extractBytes();

      return _buildOpenSshKeyPair(
        type: SshKeyAlgorithm.ed25519.sshType,
        publicKeyBlob: _buildEd25519PublicBlob(publicKey),
        comment: comment,
        passphrase: passphrase,
        writePrivateBlob: (writer) {
          writer.writeString(publicKey);
          writer.writeString(secretKey);
          writer.writeUtf8(comment);
        },
      );
    } finally {
      keyPair.dispose();
    }
  }

  static GeneratedSshKeyPair _generateEcdsa({
    required String comment,
    required SshEcdsaCurveSize curveSize,
    String? passphrase,
  }) {
    final curveId = curveSize.curveId;
    final curve = switch (curveSize) {
      SshEcdsaCurveSize.bits521 => ECCurve_secp521r1(),
      SshEcdsaCurveSize.bits384 => ECCurve_secp384r1(),
      SshEcdsaCurveSize.bits256 => ECCurve_secp256r1(),
    };
    final keyGenerator = ECKeyGenerator()
      ..init(
        ParametersWithRandom(
          ECKeyGeneratorParameters(curve),
          _newFortunaRandom(),
        ),
      );

    final pair = keyGenerator.generateKeyPair();
    final publicKey = pair.publicKey;
    final privateKey = pair.privateKey;
    final q = publicKey.Q!.getEncoded(false);

    return _buildOpenSshKeyPair(
      type: 'ecdsa-sha2-$curveId',
      publicKeyBlob: _buildEcdsaPublicBlob(curveId: curveId, q: q),
      comment: comment,
      passphrase: passphrase,
      writePrivateBlob: (writer) {
        writer.writeUtf8(curveId);
        writer.writeString(q);
        writer.writeMpInt(privateKey.d!);
        writer.writeUtf8(comment);
      },
    );
  }

  static GeneratedSshKeyPair _generateRsa({
    required String comment,
    required int bitStrength,
    String? passphrase,
  }) {
    final keyGenerator = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(BigInt.from(65537), bitStrength, 64),
          _newFortunaRandom(),
        ),
      );

    final pair = keyGenerator.generateKeyPair();
    final publicKey = pair.publicKey;
    final privateKey = pair.privateKey;
    final iqmp = privateKey.q!.modInverse(privateKey.p!);

    return _buildOpenSshKeyPair(
      type: SshKeyAlgorithm.rsa.sshType,
      publicKeyBlob: _buildRsaPublicBlob(publicKey),
      comment: comment,
      passphrase: passphrase,
      writePrivateBlob: (writer) {
        writer.writeMpInt(publicKey.modulus!);
        writer.writeMpInt(publicKey.publicExponent!);
        writer.writeMpInt(privateKey.privateExponent!);
        writer.writeMpInt(iqmp);
        writer.writeMpInt(privateKey.p!);
        writer.writeMpInt(privateKey.q!);
        writer.writeUtf8(comment);
      },
    );
  }

  static Future<SodiumSumo> _getSodium() async {
    return _sodium ??= await SodiumSumoInit.init();
  }

  static FortunaRandom _newFortunaRandom() {
    final random = FortunaRandom();
    random.seed(KeyParameter(_randomBytes(32)));
    return random;
  }

  static GeneratedSshKeyPair _buildOpenSshKeyPair({
    required String type,
    required Uint8List publicKeyBlob,
    required String comment,
    String? passphrase,
    required void Function(_SshMessageWriter writer) writePrivateBlob,
  }) {
    final privateWriter = _SshMessageWriter();
    final checkInt = _randomUint32();

    privateWriter.writeUint32(checkInt);
    privateWriter.writeUint32(checkInt);
    privateWriter.writeUtf8(type);
    writePrivateBlob(privateWriter);
    final hasPassphrase = passphrase?.isNotEmpty ?? false;
    privateWriter.padToMultipleOf(
      hasPassphrase ? SSHCipherType.aes256ctr.blockSize : 8,
    );

    final privateKey = hasPassphrase
        ? _encodeEncryptedOpenSshPrivateKey(
            publicKeyBlob: publicKeyBlob,
            privateKeyBlob: privateWriter.takeBytes(),
            passphrase: passphrase!,
          )
        : _encodeOpenSshPrivateKey(
            publicKeyBlob: publicKeyBlob,
            privateKeyBlob: privateWriter.takeBytes(),
          );

    return GeneratedSshKeyPair(
      privateKey: privateKey,
      publicKey: _encodePublicKeyLine(type, publicKeyBlob, comment: comment),
    );
  }

  static String _encodeOpenSshPrivateKey({
    required Uint8List publicKeyBlob,
    required Uint8List privateKeyBlob,
  }) {
    return OpenSSHKeyPairs.unencrypted(
      publicKeys: [publicKeyBlob],
      privateKeyBlob: privateKeyBlob,
    ).toPem();
  }

  static String _encodeEncryptedOpenSshPrivateKey({
    required Uint8List publicKeyBlob,
    required Uint8List privateKeyBlob,
    required String passphrase,
  }) {
    const cipher = SSHCipherType.aes256ctr;
    const rounds = 16;
    final salt = _randomBytes(16);
    final passphraseBytes = Uint8List.fromList(utf8.encode(passphrase));
    final kdfHash = Uint8List(cipher.keySize + cipher.ivSize);

    bcrypt_pbkdf(
      passphraseBytes,
      passphraseBytes.length,
      salt,
      salt.length,
      kdfHash,
      kdfHash.length,
      rounds,
    );

    final key = Uint8List.view(kdfHash.buffer, 0, cipher.keySize);
    final iv = Uint8List.view(kdfHash.buffer, cipher.keySize, cipher.ivSize);
    final encryptedPrivateKeyBlob = cipher
        .createCipher(key, iv, forEncryption: true)
        .processAll(privateKeyBlob);

    return OpenSSHKeyPairs(
      cipherName: cipher.name,
      kdfName: 'bcrypt',
      kdfOptions: OpenSSHBcryptKdfOptions(salt, rounds),
      publicKeys: [publicKeyBlob],
      privateKeyBlob: encryptedPrivateKeyBlob,
    ).toPem();
  }

  static Uint8List _buildRsaPublicBlob(RSAPublicKey key) {
    final writer = _SshMessageWriter();
    writer.writeUtf8(SshKeyAlgorithm.rsa.sshType);
    writer.writeMpInt(key.publicExponent!);
    writer.writeMpInt(key.modulus!);
    return writer.takeBytes();
  }

  static Uint8List _buildEcdsaPublicBlob({
    required String curveId,
    required Uint8List q,
  }) {
    final writer = _SshMessageWriter();
    writer.writeUtf8('ecdsa-sha2-$curveId');
    writer.writeUtf8(curveId);
    writer.writeString(q);
    return writer.takeBytes();
  }

  static Uint8List _buildEd25519PublicBlob(Uint8List publicKey) {
    final writer = _SshMessageWriter();
    writer.writeUtf8(SshKeyAlgorithm.ed25519.sshType);
    writer.writeString(publicKey);
    return writer.takeBytes();
  }

  static String _encodePublicKeyLine(
    String type,
    Uint8List blob, {
    String comment = '',
  }) {
    final suffix = comment.trim();
    return suffix.isEmpty
        ? '$type ${base64.encode(blob)}'
        : '$type ${base64.encode(blob)} $suffix';
  }

  static Uint8List _randomBytes(int length) {
    return Uint8List.fromList(
      List<int>.generate(length, (_) => _secureRandom.nextInt(256)),
    );
  }

  static int _randomUint32() {
    final bytes = _randomBytes(4);
    return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
  }
}

final class _SshMessageWriter {
  final BytesBuilder _builder = BytesBuilder(copy: false);

  int get length => _builder.length;

  void writeUint8(int value) => _builder.addByte(value & 0xff);

  void writeUint32(int value) {
    _builder.add([
      (value >> 24) & 0xff,
      (value >> 16) & 0xff,
      (value >> 8) & 0xff,
      value & 0xff,
    ]);
  }

  void writeBytes(Uint8List value) => _builder.add(value);

  void writeUtf8(String value) =>
      writeString(Uint8List.fromList(utf8.encode(value)));

  void writeString(Uint8List value) {
    writeUint32(value.length);
    writeBytes(value);
  }

  void writeMpInt(BigInt value) {
    if (value == BigInt.zero) {
      writeString(Uint8List(0));
      return;
    }

    var bytes = _bigIntToBytes(value);
    if (bytes.isNotEmpty && (bytes.first & 0x80) != 0) {
      bytes = Uint8List.fromList([0, ...bytes]);
    }

    writeString(bytes);
  }

  void padToMultipleOf(int blockSize) {
    for (var i = 0; length % blockSize != 0; i++) {
      writeUint8(i + 1);
    }
  }

  Uint8List takeBytes() => Uint8List.fromList(_builder.takeBytes());

  static Uint8List _bigIntToBytes(BigInt value) {
    var hex = value.toRadixString(16);
    if (hex.length.isOdd) {
      hex = '0$hex';
    }

    final result = Uint8List(hex.length ~/ 2);
    for (var i = 0; i < result.length; i++) {
      result[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return result;
  }
}
