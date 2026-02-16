package app.cliq.backend.support.encryption

data class EncryptionData(
    val userMasterKey: ByteArray,
    val dataEncryptionKey: DataEncryptionKey,
)

data class EncryptedKey(
    val nonce: ByteArray,
    val ciphertext: ByteArray,
)

data class DataEncryptionKey(
    val value: ByteArray,
    val encryptedDataEncryptionKey: EncryptedKey,
    val encryptedAndEncodedDataEncryptionKey: String,
)

data class AuthenticatedEncryptionData(
    val deviceEncryptionKey: DeviceEncryptionKey,
)

data class DeviceEncryptionKey(
    val keyPair: Pair<ByteArray, ByteArray>,
    val encryptedDataEncryptionKeyWithDeviceEncryptionKey: DataEncryptionKey,
)
