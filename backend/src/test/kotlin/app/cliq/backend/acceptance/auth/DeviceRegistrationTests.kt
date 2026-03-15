package app.cliq.backend.acceptance.auth

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.AuthExchangeRepository
import app.cliq.backend.auth.factory.AuthExchangeFactory
import app.cliq.backend.auth.params.DeviceRegistrationParams
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.constants.DEFAULT_IP_ADDRESS
import app.cliq.backend.error.ErrorCode
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.support.ErrorResponseClient
import app.cliq.backend.support.UserCreationHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper
import java.time.Clock
import java.time.OffsetDateTime
import kotlin.test.assertEquals

@AcceptanceTest
class DeviceRegistrationTests(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val clock: Clock,
    @Autowired
    private val userCreationHelper: UserCreationHelper,
    @Autowired
    private val sessionRepository: SessionRepository,
    @Autowired
    private val authExchangeFactory: AuthExchangeFactory,
    @Autowired
    private val authExchangeRepository: AuthExchangeRepository,
) : AcceptanceTester() {
    @Test
    fun `exchange code are one time use only`() {
        val ipAddress = DEFAULT_IP_ADDRESS
        val userCreationData = userCreationHelper.createRandomUser()
        val authExchange =
            authExchangeFactory.create(
                ipAddress = ipAddress,
                user = userCreationData.user,
            )

        // We can set empty string as we only test the exchange code here
        val registrationParams = DeviceRegistrationParams(authExchange.exchangeCode, "", "")
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/device/register")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(registrationParams))
                        .with {
                            it.remoteAddr = ipAddress
                            it
                        },
                ).andExpect(status().isOk)
                .andReturn()
        val content = result.response.contentAsString
        val tokenResponse = objectMapper.readValue(content, TokenResponse::class.java)

        // Assert that a new session was created
        val sessionCount = sessionRepository.count()
        assertEquals(1, sessionCount)

        // Asser that token works
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/me")
                    .header("Authorization", "Bearer ${tokenResponse.accessToken}"),
            ).andExpect(status().isOk)

        // Assert that exchange code is not valid anymore
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/device/register")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(registrationParams)),
            ).andExpect(status().isBadRequest)

        // Assert that no new session was created
        val newSessionCount = sessionRepository.count()
        assertEquals(1, newSessionCount)

        // Assert that the old session is unaffected
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/me")
                    .header("Authorization", "Bearer ${tokenResponse.accessToken}"),
            ).andExpect(status().isOk)
    }

    @Test
    fun `exchange code gets deleted after use`() {
        val ipAddress = DEFAULT_IP_ADDRESS
        val userCreationData = userCreationHelper.createRandomUser()
        val authExchange =
            authExchangeFactory.create(
                ipAddress = ipAddress,
                user = userCreationData.user,
            )

        // We can set empty string as we only test the exchange code here
        val exchangeParams = DeviceRegistrationParams(authExchange.exchangeCode, "", "")
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/device/register")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(exchangeParams))
                    .with {
                        it.remoteAddr = ipAddress
                        it
                    },
            ).andExpect(status().isOk)

        // Assert auth exchange is deleted
        val authExchangeCount = authExchangeRepository.count()
        assertEquals(0, authExchangeCount)
    }

    @Test
    fun `test auth exchange creation and retrieval`() {
        val ipAddress = "127.0.0.1"
        val userCreationData = userCreationHelper.createRandomOidcUser()
        val authExchange =
            authExchangeFactory.create(
                ipAddress = ipAddress,
                user = userCreationData.user,
            )

        // Assert no sessions exist
        val startSessionCount = sessionRepository.count()
        assertEquals(0, startSessionCount)

        // We can set empty string as we only test the exchange code here
        val exchangeParams = DeviceRegistrationParams(authExchange.exchangeCode, "", "")
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/device/register")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(exchangeParams))
                        .with {
                            it.remoteAddr = ipAddress
                            it
                        },
                ).andExpect(status().isOk)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        assertDoesNotThrow {
            objectMapper.readValue(content, TokenResponse::class.java)
        }

        val sessionCount = sessionRepository.count()
        assertEquals(1, sessionCount)

        val cont = authExchangeRepository.count()
        assertEquals(0, cont)
    }

    @Test
    fun `test cannot exchange from different ip address`() {
        val ipAddress = "127.0.0.1"
        val userCreationData = userCreationHelper.createRandomOidcUser()
        val authExchange =
            authExchangeFactory.create(
                ipAddress = ipAddress,
                user = userCreationData.user,
            )

        val startCount = authExchangeRepository.count()
        assertEquals(1, startCount)

        // We can set empty string as we only test the exchange code here
        val exchangeParams = DeviceRegistrationParams(authExchange.exchangeCode, "", "")
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/device/register")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(exchangeParams))
                        .with {
                            it.remoteAddr = "127.0.0.2"
                            it
                        },
                ).andExpect(status().isForbidden)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val response = objectMapper.readValue(content, ErrorResponseClient::class.java)
        assertEquals(ErrorCode.INVALID_IP_ADDRESS, response.errorCode)

        val count = authExchangeRepository.count()
        assertEquals(1, count)
    }

    @Test
    fun `test cannot exchange with invalid code`() {
        // We can set empty string as we only test the exchange code here
        val exchangeParams = DeviceRegistrationParams("invalid", "", "")
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/device/register")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(exchangeParams)),
                ).andExpect(status().isBadRequest)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val response = objectMapper.readValue(content, ErrorResponseClient::class.java)
        assertEquals(ErrorCode.INVALID_AUTH_EXCHANGE_CODE, response.errorCode)
    }

    @Test
    fun `test cannot exchange with expired code`() {
        val ipAddress = "127.0.0.1"
        val userCreationData = userCreationHelper.createRandomOidcUser()
        val authExchange =
            authExchangeFactory.create(
                ipAddress = ipAddress,
                user = userCreationData.user,
            )
        authExchange.expiresAt = OffsetDateTime.now(clock).minusSeconds(1)
        authExchangeRepository.saveAndFlush(authExchange)

        // We can set empty string as we only test the exchange code here
        val exchangeParams = DeviceRegistrationParams(authExchange.exchangeCode, "", "")
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/device/register")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(exchangeParams))
                        .with {
                            it.remoteAddr = ipAddress
                            it
                        },
                ).andExpect(status().isBadRequest)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val response = objectMapper.readValue(content, ErrorResponseClient::class.java)
        assertEquals(ErrorCode.INVALID_AUTH_EXCHANGE_CODE, response.errorCode)

        val cont = authExchangeRepository.count()
        assertEquals(1, cont)
    }
}
