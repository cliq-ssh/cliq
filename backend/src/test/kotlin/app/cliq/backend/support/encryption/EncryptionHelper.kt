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

        val deviceKeyPair = keyAndHashHelper.generateX25519KeyPair()

        val dataEncryptionKey = keyAndHashHelper.generateDataEncryptionKey()

        val encryptedDek = encryptDataEncryptionKeyWithDeviceEncryptionKeyPair(dataEncryptionKey, deviceKeyPair)
        val encryptedAndEncodedDek = Base64.getEncoder().encodeToString(encryptedDek.ciphertext)

        return EncryptionData(
            userMasterKey,
            DataEncryptionKey(
                dataEncryptionKey,
                encryptedDek,
                encryptedAndEncodedDek,
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
            Base64.getEncoder().encodeToString(encryptedDataEncryptionKey.ciphertext)
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

    fun encryptDeviceEncryptionKeyWithUserMasterKey(
        dek: ByteArray,
        umk: ByteArray,
    ): EncryptedKey {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")

        val nonce = ByteArray(12)
        SecureRandom().nextBytes(nonce)

        val keySpec = SecretKeySpec(umk, "AES")
        val gcmSpec = GCMParameterSpec(128, nonce)

        cipher.init(Cipher.ENCRYPT_MODE, keySpec, gcmSpec)

        val ciphertext = cipher.doFinal(dek)

        return EncryptedKey(
            nonce = nonce,
            ciphertext = ciphertext,
        )
    }

    fun encryptDataEncryptionKeyWithDeviceEncryptionKeyPair(
        dataEncryptionKey: ByteArray,
        deviceKeyPair: Pair<ByteArray, ByteArray>,
    ): EncryptedKey = encryptDeviceEncryptionKeyWithUserMasterKey(dataEncryptionKey, deviceKeyPair.second)
}
