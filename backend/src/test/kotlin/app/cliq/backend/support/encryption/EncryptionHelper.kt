package app.cliq.backend.support.encryption

import org.springframework.boot.test.context.TestComponent
import java.security.SecureRandom
import java.util.Base64
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

@TestComponent
class EncryptionHelper(
    private val keyAndHashHelper: KeyAndHashHelper,
) {
    fun createEncryptionData(
        password: String,
        salt: ByteArray,
    ): EncryptionData {
        val userMasterKey = keyAndHashHelper.generateUserMasterKey(password, salt)

        val dataEncryptionKey = keyAndHashHelper.generateDataEncryptionKey()
        val encryptedDataEncryptionKey = encryptDataWithKey(dataEncryptionKey, userMasterKey)
        val encryptedAndEncodedDataEncryptionKey = Base64.getEncoder().encodeToString(encryptedDataEncryptionKey)

        return EncryptionData(
            userMasterKey,
            DataEncryptionKey(
                dataEncryptionKey,
                encryptedDataEncryptionKey,
                encryptedAndEncodedDataEncryptionKey,
            ),
        )
    }

    fun createAuthenticatedEncryptionData(encryptionData: EncryptionData): AuthenticatedEncryptionData {
        val deviceEncryptionKeyPair = keyAndHashHelper.generateX25519KeyPair()
        val encryptedDataEncryptionKey =
            encryptDataEncryptionKeyWithDeviceEncryptionKeyPair(
                encryptionData.dataEncryptionKey.value,
                deviceEncryptionKeyPair,
            )
        val encryptedAndEncodedDataEncryptionKey =
            Base64.getEncoder().encodeToString(encryptedDataEncryptionKey)
        val deviceEncryptionKey =
            DeviceEncryptionKey(
                deviceEncryptionKeyPair,
                DataEncryptionKey(
                    encryptionData.dataEncryptionKey.value,
                    encryptedDataEncryptionKey,
                    encryptedAndEncodedDataEncryptionKey,
                ),
            )

        return AuthenticatedEncryptionData(
            deviceEncryptionKey,
        )
    }

    fun decryptDataWithKey(
        encryptedDek: ByteArray,
        userMasterKey: ByteArray,
    ): ByteArray {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")

        val nonce = encryptedDek.copyOfRange(0, 12)
        val ciphertext = encryptedDek.copyOfRange(12, encryptedDek.size)

        val keySpec = SecretKeySpec(userMasterKey, "AES")
        val gcmSpec = GCMParameterSpec(128, nonce)

        cipher.init(Cipher.DECRYPT_MODE, keySpec, gcmSpec)

        return cipher.doFinal(ciphertext)
    }

    fun encryptDataWithKey(
        dek: ByteArray,
        umk: ByteArray,
    ): ByteArray {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")

        val nonce = ByteArray(12)
        SecureRandom().nextBytes(nonce)

        val keySpec = SecretKeySpec(umk, "AES")
        val gcmSpec = GCMParameterSpec(128, nonce)

        cipher.init(Cipher.ENCRYPT_MODE, keySpec, gcmSpec)

        val ciphertext = cipher.doFinal(dek)

        val encryptedData = nonce + ciphertext

        return encryptedData
    }

    fun encryptDataEncryptionKeyWithDeviceEncryptionKeyPair(
        dataEncryptionKey: ByteArray,
        deviceKeyPair: Pair<ByteArray, ByteArray>,
    ): ByteArray = encryptDataWithKey(dataEncryptionKey, deviceKeyPair.second)
}
