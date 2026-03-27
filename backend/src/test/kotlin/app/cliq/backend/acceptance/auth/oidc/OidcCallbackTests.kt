package app.cliq.backend.acceptance.auth.oidc

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.AuthExchangeRepository
import app.cliq.backend.auth.factory.OidcCallbackTokenFactory
import app.cliq.backend.auth.params.DeviceRegistrationParams
import app.cliq.backend.auth.params.OidcCallbackParams
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.auth.view.login.LoginFinishResponse
import app.cliq.backend.constants.DEFAULT_IP_ADDRESS
import app.cliq.backend.error.ErrorCode
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.support.ErrorResponseClient
import app.cliq.backend.support.UserCreationHelper
import org.junit.jupiter.api.Assertions.assertEquals
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

@AcceptanceTest
class OidcCallbackTests(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val authExchangeRepository: AuthExchangeRepository,
    @Autowired
    private val sessionRepository: SessionRepository,
    @Autowired
    private val userCreationHelper: UserCreationHelper,
    @Autowired
    private val clock: Clock,
    @Autowired
    private val oidcCallbackTokenFactory: OidcCallbackTokenFactory,
) : AcceptanceTester() {
    @Test
    fun `test callback token creation and retrieval`() {
        val ipAddress = DEFAULT_IP_ADDRESS
        val userCreationData = userCreationHelper.createRandomOidcUser()
        val callbackToken = oidcCallbackTokenFactory.create(ipAddress, userCreationData.user, null)

        // Assert no sessions exist
        val startSessionCount = sessionRepository.count()
        assertEquals(0, startSessionCount)

        val callbackParams = OidcCallbackParams(callbackToken.token)
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/oidc/callback")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(callbackParams))
                        .with {
                            it.remoteAddr = ipAddress
                            it
                        },
                ).andExpect(status().isOk)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val loginFinishResponse = objectMapper.readValue(content, LoginFinishResponse::class.java)
        assertEquals(callbackToken.authExchange.exchangeCode, loginFinishResponse.authExchangeCode)
    }

    @Test
    fun `test cannot exchange from different ip address`() {
        val ipAddress = DEFAULT_IP_ADDRESS
        val userCreationData = userCreationHelper.createRandomOidcUser()
        val callbackToken = oidcCallbackTokenFactory.create(ipAddress, userCreationData.user, null)

        val callbackParams = OidcCallbackParams(callbackToken.token)
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/oidc/callback")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(callbackParams))
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
        val callbackParams = OidcCallbackParams("invalid")
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/oidc/callback")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(callbackParams)),
                ).andExpect(status().isBadRequest)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val response = objectMapper.readValue(content, ErrorResponseClient::class.java)
        assertEquals(ErrorCode.INVALID_OIDC_CALLBACK_TOKEN, response.errorCode)
    }

    @Test
    fun `test cannot exchange with expired code`() {
        val ipAddress = DEFAULT_IP_ADDRESS
        val userCreationData = userCreationHelper.createRandomOidcUser()
        val callbackToken = oidcCallbackTokenFactory.create(ipAddress, userCreationData.user, null)
        val authExchange = authExchangeRepository.findById(callbackToken.authExchange.id!!).orElseThrow()
        authExchange.expiresAt = OffsetDateTime.now(clock).minusSeconds(1)
        authExchangeRepository.saveAndFlush(authExchange)

        val callbackParams = OidcCallbackParams(callbackToken.token)
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/oidc/callback")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(callbackParams))
                        .with {
                            it.remoteAddr = ipAddress
                            it
                        },
                ).andExpect(status().isBadRequest)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val response = objectMapper.readValue(content, ErrorResponseClient::class.java)
        assertEquals(ErrorCode.INVALID_OIDC_CALLBACK_TOKEN, response.errorCode)

        val cont = authExchangeRepository.count()
        assertEquals(1, cont)
    }

    @Test
    fun `test callback token to exchange code to session workflow`() {
        val ipAddress = DEFAULT_IP_ADDRESS
        val userCreationData = userCreationHelper.createRandomOidcUser()
        val callbackToken = oidcCallbackTokenFactory.create(ipAddress, userCreationData.user, null)

        // Assert no sessions exist
        val startSessionCount = sessionRepository.count()
        assertEquals(0, startSessionCount)

        // OIDC callback
        val callbackParams = OidcCallbackParams(callbackToken.token)
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/oidc/callback")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(callbackParams))
                        .with {
                            it.remoteAddr = ipAddress
                            it
                        },
                ).andExpect(status().isOk)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val loginFinishResponse = objectMapper.readValue(content, LoginFinishResponse::class.java)

        // Auth exchange
        val registrationParams = DeviceRegistrationParams(loginFinishResponse.authExchangeCode, "", "")
        val registrationResult =
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
        val registrationContent = registrationResult.response.contentAsString
        assert(registrationContent.isNotEmpty())
        assertDoesNotThrow { objectMapper.readValue(registrationContent, TokenResponse::class.java) }
    }
}
