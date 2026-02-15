package app.cliq.backend.support.encryption

data class EncryptionData(
    val userMasterKey: ByteArray,
    val dataEncryptionKey: DataEncryptionKey,
)

data class EncryptedDEK(
    val nonce: ByteArray,
    val ciphertext: ByteArray,
)

data class DataEncryptionKey(
    val value: ByteArray,
    val encryptedDEK: EncryptedDEK,
    val encryptedAndEncodedDEK: String
)
