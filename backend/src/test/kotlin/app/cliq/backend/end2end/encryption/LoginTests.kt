package app.cliq.backend.end2end.encryption

import app.cliq.backend.auth.params.DeviceRegistrationParams
import app.cliq.backend.auth.params.login.LoginFinishParams
import app.cliq.backend.auth.params.login.LoginStartParams
import app.cliq.backend.auth.service.SrpService
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.auth.view.login.LocalLoginFinishResponse
import app.cliq.backend.auth.view.login.LoginStartResponse
import app.cliq.backend.end2end.End2EndTest
import app.cliq.backend.end2end.End2EndTester
import app.cliq.backend.support.UserCreationHelper
import app.cliq.backend.support.encryption.EncryptionHelper
import app.cliq.backend.support.encryption.KeyAndHashHelper
import com.nimbusds.srp6.BigIntegerUtils
import com.nimbusds.srp6.SRP6ClientSession
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.junit.jupiter.api.assertNotNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper
import java.util.Base64
import kotlin.test.assertContentEquals
import kotlin.test.assertEquals

@End2EndTest
class LoginTests(
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val userCreationHelper: UserCreationHelper,
    @Autowired
    private val srpService: SrpService,
    @Autowired
    private val encryptionHelper: EncryptionHelper,
    @Autowired
    private val keyAndHelper: KeyAndHashHelper,
) : End2EndTester() {
    @Test
    fun `test login`() {
        val creationData = userCreationHelper.createRandomUser()
        val email = creationData.user.email
        val password = creationData.password

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
        val loginFinishResponse = objectMapper.readValue(loginFinishContent, LocalLoginFinishResponse::class.java)

        val encryptedAndEncodedDataEncryptionKey = loginFinishResponse.dataEncryptionKeyUmkWrapped
        assertNotNull(encryptedAndEncodedDataEncryptionKey)
        assertEquals(
            creationData.encryptionData.dataEncryptionKey.encryptedAndEncodedDataEncryptionKey,
            encryptedAndEncodedDataEncryptionKey,
        )

        // Verify Server Response
        val step3BigInteger = BigIntegerUtils.fromHex(loginFinishResponse.publicM2)
        // If it throws, the Server is not trustworthy
        assertDoesNotThrow { srpClientSession.step3(step3BigInteger) }

        // Authentication successfully

        // Create User Master Key
        val saltByteArray = BigIntegerUtils.bigIntegerToBytes(saltBigInteger)
        val userMasterKey = keyAndHelper.generateUserMasterKey(password, saltByteArray)

        // Decrypt Data Encryption Key
        val decodedAndEncryptedDataEncryptionKey = Base64.getDecoder().decode(encryptedAndEncodedDataEncryptionKey)
        val dataEncryptionKey =
            assertDoesNotThrow {
                encryptionHelper.decryptDataWithKey(
                    decodedAndEncryptedDataEncryptionKey,
                    userMasterKey,
                )
            }
        assertContentEquals(creationData.encryptionData.dataEncryptionKey.value, dataEncryptionKey)

        // Generate Device Encryption Pair
        val deviceEncryptionPair = keyAndHelper.generateX25519KeyPair()
        val encryptedDataEncryptionKey =
            assertDoesNotThrow {
                encryptionHelper.encryptDataEncryptionKeyWithDeviceEncryptionKeyPair(
                    dataEncryptionKey,
                    deviceEncryptionPair,
                )
            }
        val encodedAndEncryptedDataEncryptionKey = Base64.getEncoder().encodeToString(encryptedDataEncryptionKey)
        val encodedDevicePublicKey = Base64.getEncoder().encodeToString(deviceEncryptionPair.first)

        val deviceRegistrationParams =
            DeviceRegistrationParams(
                loginFinishResponse.authExchangeCode,
                encodedDevicePublicKey,
                encodedAndEncryptedDataEncryptionKey,
            )
        val registrationResult =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/device/register")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(deviceRegistrationParams)),
                ).andExpect(status().isOk)
                .andReturn()
        val registrationResultContent = registrationResult.response.contentAsString
        val tokenResponse = objectMapper.readValue(registrationResultContent, TokenResponse::class.java)
        println(tokenResponse)
    }
}
