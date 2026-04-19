import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// A simple password-based encryption scheme using AES-256-GCM and Argon2id for key derivation.
class PasswordCipher {
  const PasswordCipher._();

  static const List<int> _magic = [0x50, 0x43, 0x58, 0x31];
  static const int _version = 1;
  static const int _kdfArgon2id = 1;

  static const int _saltLength = 16;
  static const int _nonceLength = 12;

  static const int _keyLength = 32;
  static const int _macSizeBits = 128;

  static const int _argon2Iterations = 3;
  static const int _argon2MemoryKiB = 65536;
  static const int _argon2Lanes = 4;

  /// Encrypts the given [text] using the provided [password]. Returns a byte array containing the encrypted data.
  static Uint8List encrypt(String text, String password) {
    final salt = _randomBytes(_saltLength);
    final nonce = _randomBytes(_nonceLength);
    final plaintext = Uint8List.fromList(utf8.encode(text));
    final aad = _buildHeader(salt: salt, nonce: nonce);
    final key = _deriveKey(password, salt);

    try {
      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          true,
          AEADParameters(KeyParameter(key), _macSizeBits, nonce, aad),
        );

      final out = Uint8List(cipher.getOutputSize(plaintext.length));
      var outLen = cipher.processBytes(plaintext, 0, plaintext.length, out, 0);
      outLen += cipher.doFinal(out, outLen);

      final result = BytesBuilder()
        ..add(aad)
        ..add(out.sublist(0, outLen));

      return result.toBytes();
    } finally {
      _wipe(key);
      _wipe(plaintext);
    }
  }

  /// Decrypts the given [encryptedData] using the provided [password]. Returns the original plaintext string.
  static Uint8List decrypt(Uint8List encryptedData, String password) {
    if (!isEncrypted(encryptedData)) {
      throw FormatException('Not a valid encrypted payload.');
    }

    final saltLen = encryptedData[15];
    final nonceLen = encryptedData[16];
    final headerLen = 17 + saltLen + nonceLen;

    final aad = encryptedData.sublist(0, headerLen);
    final salt = encryptedData.sublist(17, 17 + saltLen);
    final nonce = encryptedData.sublist(17 + saltLen, headerLen);
    final ciphertext = encryptedData.sublist(headerLen);

    final key = _deriveKey(password, salt);

    try {
      final cipher = GCMBlockCipher(AESEngine())
        ..init(
          false,
          AEADParameters(KeyParameter(key), _macSizeBits, nonce, aad),
        );

      final out = Uint8List(cipher.getOutputSize(ciphertext.length));
      var outLen = cipher.processBytes(
        ciphertext,
        0,
        ciphertext.length,
        out,
        0,
      );
      outLen += cipher.doFinal(out, outLen);

      return out.sublist(0, outLen);
    } on InvalidCipherTextException {
      throw FormatException('Wrong password or corrupted data.');
    } finally {
      _wipe(key);
    }
  }

  /// Checks if the given [data] is in the expected encrypted format.
  static bool isEncrypted(Uint8List data) {
    if (data.length < 61) return false;

    for (var i = 0; i < 4; i++) {
      if (data[i] != _magic[i]) return false;
    }

    if (data[4] != _version) return false;
    if (data[5] != _kdfArgon2id) return false;
    if (data[15] != _saltLength) return false;
    if (data[16] != _nonceLength) return false;

    // at least the gcm tag must be present
    return data.length >= (17 + data[15] + data[16]) + 16;
  }

  /// Derives a cryptographic key from the given [password] and [salt] using the Argon2id key derivation function
  /// with predefined parameters.
  static Uint8List _deriveKey(String password, Uint8List salt) {
    final passwordBytes = Uint8List.fromList(utf8.encode(password));

    try {
      final generator = Argon2BytesGenerator()
        ..init(
          Argon2Parameters(
            Argon2Parameters.ARGON2_id,
            salt,
            desiredKeyLength: _keyLength,
            iterations: _argon2Iterations,
            memory: _argon2MemoryKiB,
            lanes: _argon2Lanes,
            version: Argon2Parameters.ARGON2_VERSION_13,
          ),
        );

      final key = Uint8List(_keyLength);
      generator.deriveKey(passwordBytes, 0, key, 0);
      return key;
    } finally {
      _wipe(passwordBytes);
    }
  }

  /// Helper method to build the header containing metadata and parameters for encryption.
  /// This includes the [_magic] bytes, [_version], [_kdfArgon2id], Argon2 parameters,
  /// and the randomly generated [salt] and [nonce].
  static Uint8List _buildHeader({
    required Uint8List salt,
    required Uint8List nonce,
  }) {
    final header = BytesBuilder()
      ..add(_magic)
      ..add([_version, _kdfArgon2id])
      ..add(_u32(_argon2Iterations))
      ..add(_u32(_argon2MemoryKiB))
      ..add([_argon2Lanes, salt.length, nonce.length])
      ..add(salt)
      ..add(nonce);

    return header.toBytes();
  }

  /// Helper method to generate secure random bytes of the specified [length].
  static Uint8List _randomBytes(int length) {
    final rng = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => rng.nextInt(256)),
    );
  }

  /// Helper method to convert a 32-bit integer to a big-endian byte array.
  static Uint8List _u32(int value) {
    final bd = ByteData(4)..setUint32(0, value, .big);
    return bd.buffer.asUint8List();
  }

  /// Helper method to securely wipe sensitive data from memory by zeroing out the byte array.
  static void _wipe(Uint8List bytes) {
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = 0;
    }
  }
}
