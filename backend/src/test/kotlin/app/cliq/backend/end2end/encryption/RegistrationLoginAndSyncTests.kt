package app.cliq.backend.end2end.encryption

import app.cliq.backend.auth.params.RefreshParams
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.auth.params.login.LoginFinishParams
import app.cliq.backend.auth.params.login.LoginStartParams
import app.cliq.backend.auth.service.SrpService
import app.cliq.backend.auth.view.TokenResponse
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
import com.nimbusds.srp6.BigIntegerUtils
import com.nimbusds.srp6.SRP6ClientSession
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers
import tools.jackson.databind.ObjectMapper
import java.security.SecureRandom
import java.util.Base64

@End2EndTest
class RegistrationLoginAndSyncTests(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val keyAndHashHelper: KeyAndHashHelper,
    @Autowired
    private val encryptionHelper: EncryptionHelper,
    @Autowired
    private val srpService: SrpService,
) : End2EndTester() {
    private val secureRandom: SecureRandom = SecureRandom.getInstanceStrong()

    /**
     * This test should test the whole registration and login flow, including actions that are being done by the frontend.
     */
    @Test
    fun `test registration with keys creation`() {
        val email = EXAMPLE_EMAIL
        val password = DEFAULT_PASSWORD

        // Generate salt
        val salt = ByteArray(16)
        secureRandom.nextBytes(salt)

        // Generate UMK
        val userMasterKey = keyAndHashHelper.generateUserMasterKey(password, salt)

        // Generate DEK
        val dataEncryptionKey = keyAndHashHelper.generateDataEncryptionKey()
        // dek would be saved to a private key store

        // Encrypt DEK with UMK
        val encryptedDek =
            encryptionHelper.encryptDataWithKey(dataEncryptionKey, userMasterKey)
        val encryptedDekString = Base64.getEncoder().encodeToString(encryptedDek)

        // umk should be "dropped" here, only salt should be saved for later use in login

        // Generate DeviceKeyPair
        val deviceKeyPair = keyAndHashHelper.generateX25519KeyPair()

        // Encrypt DEK with DeviceKeyPair
        val encryptedDekWithDeviceKeyPair =
            encryptionHelper.encryptDataEncryptionKeyWithDeviceEncryptionKeyPair(
                dataEncryptionKey,
                deviceKeyPair,
            )
        val encryptedDekWithDeviceKeyPairString =
            Base64.getEncoder().encodeToString(encryptedDekWithDeviceKeyPair)

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
                ).andExpect(MockMvcResultMatchers.status().isCreated)
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
                ).andExpect(MockMvcResultMatchers.status().isOk)
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
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andReturn()
        val loginFinishContent = loginFinishResult.response.contentAsString
        val loginFinishResponse = objectMapper.readValue(loginFinishContent, LoginFinishResponse::class.java)

        // Verify Server Response
        val step3BigInteger = BigIntegerUtils.fromHex(loginFinishResponse.publicM2)
        // If it throws the Server is not trust worthy
        assertDoesNotThrow { srpClientSession.step3(step3BigInteger) }

        // Authentication successfully

        // Test login with the new access token by getting self the user information
        val tokenResponse = loginFinishResponse.session
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/me")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer ${tokenResponse.accessToken}"),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Refresh
        val refreshParams = RefreshParams(tokenResponse.refreshToken)
        val refreshResult =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(refreshParams)),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andReturn()
        val refreshContent = refreshResult.response.contentAsString
        val refreshResponse = objectMapper.readValue(refreshContent, TokenResponse::class.java)

        // Test login with the new access token by getting self the user information
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/me")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer ${refreshResponse.accessToken}"),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // logout
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/logout")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer ${refreshResponse.accessToken}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(refreshParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)
    }
}
