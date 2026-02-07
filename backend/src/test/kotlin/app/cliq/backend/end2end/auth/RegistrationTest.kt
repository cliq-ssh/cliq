package app.cliq.backend.end2end.auth

import app.cliq.backend.constants.EXAMPLE_EMAIL
import app.cliq.backend.constants.EXAMPLE_PASSWORD
import app.cliq.backend.end2end.End2EndTest
import app.cliq.backend.end2end.End2EndTester
import app.cliq.backend.support.EncryptionHelper
import app.cliq.backend.support.KeyAndHashHelper
import app.cliq.backend.utils.TokenGenerator
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired

@End2EndTest
class RegistrationTest(
    @Autowired
    private val tokenGenerator: TokenGenerator,
    @Autowired
    private val keyAndHashHelper: KeyAndHashHelper,
    @Autowired
    private val encryptionHelper: EncryptionHelper,
) : End2EndTester() {
    /**
     * This test should test the whole registration flow, including actions that are being done by the frontend.
     */
    @Test
    fun `test registration with keys creation`() {
        val email = EXAMPLE_EMAIL
        val password = EXAMPLE_PASSWORD

        // Generate salt
        val salt = tokenGenerator.generateToken(16U)

        // Generate UMK
        val argon2Generator = keyAndHashHelper.buildArgon2BytesGenerator(salt)
        val umk =  ByteArray(32)
        argon2Generator.generateBytes(password.toByteArray(), umk)

        // Generate DeviceKeyPair
        val deviceKeyPair = keyAndHashHelper.generateX25519KeyPair()

        // Generate DEK
        val dek = tokenGenerator.generateToken(32U).toByteArray()
        // dek would be saved to a private key store

        // Encrypt DEK with UMK
        val encryptedDek = encryptionHelper.encryptDEKWithUMK(dek, umk)
        // umk should be "dropped" here, only salt should be saved for later use in login

        // Encrypt DEK with DeviceKeyPair
        val encryptedDekWithDeviceKeyPair = encryptionHelper.encryptDEKWithDeviceKeyPair(dek, deviceKeyPair)

        // Encrypt DEK with DeviceKeyPair
        println()
    }
}
