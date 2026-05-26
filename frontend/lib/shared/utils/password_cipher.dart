import 'dart:typed_data';

import 'package:sodium/sodium_sumo.dart';

/// Utility class for encrypting and decrypting data with a password using the sodium library.
class PasswordCipher {
  static PasswordCipher? _instance;

  /// A fixed header to identify the whether the data is encrypted.
  static final Uint8List _header = Uint8List.fromList(
    "cliq-encrypted".codeUnits,
  );

  final SodiumSumo _sodium;

  const PasswordCipher._(this._sodium);

  static PasswordCipher get instance {
    if (_instance == null) {
      throw Exception(
        'PasswordCipher is not initialized. Call PasswordCipher.init() first.',
      );
    }
    return _instance!;
  }

  /// Initializes the PasswordCipher. Must be called before using the instance.
  static Future<void> init() async {
    _instance = PasswordCipher._(await SodiumSumoInit.init());
  }

  /// Encrypts the given [plaintext] using a key derived from the [password].
  Future<Uint8List> encrypt(Uint8List plaintext, Uint8List password) async {
    final aead = _sodium.crypto.aeadXChaCha20Poly1305IETF;
    final salt = _sodium.randombytes.buf(_sodium.crypto.pwhash.saltBytes);
    final nonce = _sodium.randombytes.buf(aead.nonceBytes);
    final key = await _deriveKey(password, salt);
    try {
      return Uint8List.fromList([
        ..._header,
        ...salt,
        ...nonce,
        ...aead.encrypt(message: plaintext, nonce: nonce, key: key),
      ]);
    } finally {
      key.dispose();
    }
  }

  /// Decrypts the given [data] using a key derived from the [password].
  Future<Uint8List> decrypt(Uint8List data, Uint8List password) async {
    if (!_hasValidMagic(data)) {
      throw const FormatException('Invalid payload.');
    }

    final aead = _sodium.crypto.aeadXChaCha20Poly1305IETF;
    final saltLen = _sodium.crypto.pwhash.saltBytes;
    final nonceLen = aead.nonceBytes;

    // strip header
    final payload = data.sublist(_header.length);

    if (payload.length < saltLen + nonceLen + aead.aBytes) {
      throw const FormatException('Invalid payload.');
    }

    final key = await _deriveKey(password, payload.sublist(0, saltLen));
    try {
      return aead.decrypt(
        cipherText: payload.sublist(saltLen + nonceLen),
        nonce: payload.sublist(saltLen, saltLen + nonceLen),
        key: key,
      );
    } on SodiumException {
      throw const FormatException('Wrong password or corrupted payload.');
    } finally {
      key.dispose();
    }
  }

  /// Checks if the given [data] is in the expected encrypted format.
  /// This does not guarantee that the data can be decrypted successfully, only that it has the correct header.
  bool isEncrypted(Uint8List data) {
    return _hasValidMagic(data);
  }

  /// Checks if the given [data] starts with the expected header.
  bool _hasValidMagic(Uint8List data) {
    if (data.length < _header.length) return false;
    for (int i = 0; i < _header.length; i++) {
      if (data[i] != _header[i]) return false;
    }
    return true;
  }

  /// Derives a key from the given [password] and [salt] using the Argon2id algorithm in an isolate, to avoid
  /// blocking the main thread.
  Future<SecureKey> _deriveKey(Uint8List password, Uint8List salt) {
    return _sodium.runIsolated(
      (_, _) => _sodium.crypto.pwhash(
        outLen: _sodium.crypto.aeadXChaCha20Poly1305IETF.keyBytes,
        password: password.buffer.asInt8List(
          password.offsetInBytes,
          password.lengthInBytes,
        ),
        salt: salt,
        opsLimit: _sodium.crypto.pwhash.opsLimitModerate,
        memLimit: _sodium.crypto.pwhash.memLimitModerate,
        alg: CryptoPwhashAlgorithm.argon2id13,
      ),
    );
  }
}
