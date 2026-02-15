package app.cliq.backend.support.encryption

import org.springframework.boot.test.context.TestComponent
import java.security.SecureRandom
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.SecretKeySpec

@TestComponent
class EncryptionHelper {
    fun encryptDEKWithUMK(
        dek: ByteArray,
        umk: ByteArray,
    ): EncryptedDEK {
        val cipher = Cipher.getInstance("AES/GCM/NoPadding")

        val nonce = ByteArray(12)
        SecureRandom().nextBytes(nonce)

        val keySpec = SecretKeySpec(umk, "AES")
        val gcmSpec = GCMParameterSpec(128, nonce)

        cipher.init(Cipher.ENCRYPT_MODE, keySpec, gcmSpec)

        val ciphertext = cipher.doFinal(dek)

        return EncryptedDEK(
            nonce = nonce,
            ciphertext = ciphertext,
        )
    }

    fun encryptDEKWithDeviceKeyPair(
        dek: ByteArray,
        deviceKeyPair: Pair<ByteArray, ByteArray>,
    ): EncryptedDEK = encryptDEKWithUMK(dek, deviceKeyPair.second)
}
