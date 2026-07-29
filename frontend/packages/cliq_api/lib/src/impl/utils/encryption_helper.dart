import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:dsrp/crypto/kdf.dart';

final BigInt srpSafePrime2048 = BigInt.parse(
  '21766174458617435773191008891802753781907668374255538511144643224689886'
  '23538384095721090901308605640157139971723580726658164960647214841029141'
  '33641521973644771808873956554837381150726774022351017625219015698207402'
  '93149529620419333266262073471054548368736039519702486226506248861060256'
  '97180298495356112144268015766800076142998822245709041387397397017192709'
  '39921147517651680636147611196154762334220964427831179712363716473338714'
  '14335895773474667308967050807005509320424799678417036867928316761272274'
  '23031406754829113358247958306143957755934710196177140617368437852270348'
  '3495337037655006751328447510550299250924469288819',
);

class EncryptionHelper {
  final Random _secureRandom;

  EncryptionHelper([Random? secureRandom])
    : _secureRandom = secureRandom ?? Random.secure();

  Argon2idKdf buildArgon2idKdf() {
    return createArgon2idKdf(
      parallelism: 1,
      memoryInKB: 65536,
      iterations: 2,
      hashLength: 32,
    );
  }

  /// Derives the User Master Key (UMK) from [password] and [salt].
  Future<Uint8List> generateUserMasterKey(Uint8List password, Uint8List salt) {
    return buildArgon2idKdf().deriveKeyFromPasswordBytes(
      passwordBytes: password,
      salt: salt,
    );
  }

  /// Generates a random salt of the specified [length] using a secure
  /// random number generator.
  Uint8List generateSalt(int length) {
    final salt = Uint8List(length);
    for (int i = 0; i < length; i++) {
      salt[i] = _secureRandom.nextInt(256);
    }
    return salt;
  }

  /// Generates a random 32-byte Data Encryption Key (DEK).
  Uint8List generateDataEncryptionKey() => generateSalt(32);

  /// Encrypts [data] with [key] using AES-256-GCM.
  Future<Uint8List> encryptDataWithKey(Uint8List data, Uint8List key) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKeyData(key);
    final secretBox = await algorithm.encrypt(data, secretKey: secretKey);
    return Uint8List.fromList([
      ...secretBox.nonce,
      ...secretBox.cipherText,
      ...secretBox.mac.bytes,
    ]);
  }

  /// Decrypts [encryptedData] with [key] using AES-256-GCM.
  Future<Uint8List> decryptDataWithKey(
    Uint8List encryptedData,
    Uint8List key,
  ) async {
    final algorithm = AesGcm.with256bits();
    final secretKey = SecretKeyData(key);
    final nonce = encryptedData.sublist(0, 12);
    final tag = encryptedData.sublist(encryptedData.length - 16);
    final cipherText = encryptedData.sublist(12, encryptedData.length - 16);
    final secretBox = SecretBox(cipherText, nonce: nonce, mac: Mac(tag));
    final plainText = await algorithm.decrypt(secretBox, secretKey: secretKey);
    return Uint8List.fromList(plainText);
  }

  Future<(Uint8List publicKey, Uint8List privateKey)>
  generateX25519KeyPair() async {
    final algorithm = X25519();
    final keyPair = await algorithm.newKeyPair();
    final publicKey = await keyPair.extractPublicKey();
    final privateKeyBytes = await keyPair.extractPrivateKeyBytes();
    return (
      Uint8List.fromList(publicKey.bytes),
      Uint8List.fromList(privateKeyBytes),
    );
  }

  Future<Uint8List> encryptDataEncryptionKeyWithDeviceEncryptionKeyPair(
    Uint8List dataEncryptionKey,
    (Uint8List publicKey, Uint8List privateKey) deviceKeyPair,
  ) {
    return encryptDataWithKey(dataEncryptionKey, deviceKeyPair.$2);
  }

  Future<Uint8List> decryptDataEncryptionKeyWithDeviceEncryptionKeyPair(
    Uint8List encryptedDek,
    Uint8List devicePrivateKey,
  ) {
    return decryptDataWithKey(encryptedDek, devicePrivateKey);
  }
}
