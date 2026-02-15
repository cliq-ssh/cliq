package app.cliq.backend.end2end.auth

import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.auth.params.login.LoginFinishParams
import app.cliq.backend.auth.params.login.LoginStartParams
import app.cliq.backend.auth.service.SrpService
import app.cliq.backend.auth.view.login.LoginFinishResponse
import app.cliq.backend.auth.view.login.LoginStartResponse
import app.cliq.backend.constants.DEFAULT_PASSWORD
import app.cliq.backend.constants.EXAMPLE_EMAIL
import app.cliq.backend.constants.EXAMPLE_USERNAME
import app.cliq.backend.end2end.End2EndTest
import app.cliq.backend.end2end.End2EndTester
import app.cliq.backend.support.encryption.EncryptionHelper
import app.cliq.backend.support.encryption.KeyAndHashHelper
import app.cliq.backend.user.view.UserResponse
import app.cliq.backend.utils.TokenGenerator
import com.nimbusds.srp6.BigIntegerUtils
import com.nimbusds.srp6.SRP6ClientSession
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper
import java.security.SecureRandom
import java.util.Base64

@End2EndTest
class RegistrationTest(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val tokenGenerator: TokenGenerator,
    @Autowired
    private val keyAndHashHelper: KeyAndHashHelper,
    @Autowired
    private val encryptionHelper: EncryptionHelper,
    @Autowired
    private val srpService: SrpService,
) : End2EndTester() {
    private val secureRandom: SecureRandom = SecureRandom.getInstanceStrong()

    /**
     * This test should test the whole registration flow, including actions that are being done by the frontend.
     */
    @Test
    fun `test registration with keys creation`() {
        val email = EXAMPLE_EMAIL
        val password = DEFAULT_PASSWORD

        // Generate salt
        val salt = ByteArray(16)
        secureRandom.nextBytes(salt)

        // Generate UMK
        val argon2Generator = keyAndHashHelper.buildArgon2BytesGenerator(salt)
        val umk = ByteArray(32)
        argon2Generator.generateBytes(password.toByteArray(), umk)

        // Generate DeviceKeyPair
        val deviceKeyPair = keyAndHashHelper.generateX25519KeyPair()

        // Generate DEK
        val dek = tokenGenerator.generateToken(32U).toByteArray()
        // dek would be saved to a private key store

        // Encrypt DEK with UMK
        val encryptedDek = encryptionHelper.encryptDEKWithUMK(dek, umk)
        val encryptedDekString = Base64.getEncoder().encodeToString(encryptedDek.ciphertext)

        // umk should be "dropped" here, only salt should be saved for later use in login

        // Encrypt DEK with DeviceKeyPair
        val encryptedDekWithDeviceKeyPair = encryptionHelper.encryptDEKWithDeviceKeyPair(dek, deviceKeyPair)
        val encryptedDekWithDeviceKeyPairString =
            Base64.getEncoder().encodeToString(encryptedDekWithDeviceKeyPair.ciphertext)

        val srpSaltBigInteger = BigIntegerUtils.bigIntegerFromBytes(salt)
        // Generate SRP Verifier
        val srpVerifier =
            srpService.verifierGen.generateVerifier(srpSaltBigInteger, email, password)
        val srpVerifierString = BigIntegerUtils.toHex(srpVerifier)
        val srpSaltString = BigIntegerUtils.toHex(srpSaltBigInteger)

        // Register user
        val registrationParams =
            RegistrationParams(
                email,
                EXAMPLE_USERNAME,
                encryptedDekString,
                srpSaltString,
                srpVerifierString,
            )
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/register")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(registrationParams)),
                ).andExpect(status().isCreated)
                .andReturn()

        val content = result.response.contentAsString
        val response = objectMapper.readValue(content, UserResponse::class.java)

        // Login //

        // Create a new client session
        val srpClientSession = SRP6ClientSession()
        srpClientSession.step1(email, password)

        // Start the backend login process
        val loginStartParams = LoginStartParams(email)
        val loginStartResult =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/login/start")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(loginStartParams)),
                ).andExpect(status().isOk)
                .andReturn()
        val loginStartContent = loginStartResult.response.contentAsString
        val loginStartResponse = objectMapper.readValue(loginStartContent, LoginStartResponse::class.java)

        val publicBBigInteger = BigIntegerUtils.fromHex(loginStartResponse.publicB)
        val saltBigInteger = BigIntegerUtils.fromHex(loginStartResponse.salt)

        // Compute client public value
        val credentials =
            // If throws then login was not successful
            assertDoesNotThrow { srpClientSession.step2(srpService.params, saltBigInteger, publicBBigInteger) }

        val publicA = BigIntegerUtils.toHex(credentials.A)
        val publicM1 = BigIntegerUtils.toHex(credentials.M1)
        val loginFinishParams =
            LoginFinishParams(loginStartResponse.authenticationSessionToken, publicA, publicM1)

        val loginFinishResult =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/login/finish")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(loginFinishParams)),
                ).andExpect(status().isOk)
                .andReturn()
        val loginFinishContent = loginFinishResult.response.contentAsString
        val loginFinishResponse = objectMapper.readValue(loginFinishContent, LoginFinishResponse::class.java)

        // Verify Server Response
        val step3BigInteger = BigIntegerUtils.fromHex(loginFinishResponse.publicM2)
        // If it throws the Server is not trust worthy
        assertDoesNotThrow { srpClientSession.step3(step3BigInteger) }

        // Authentication successfully
    }
}
