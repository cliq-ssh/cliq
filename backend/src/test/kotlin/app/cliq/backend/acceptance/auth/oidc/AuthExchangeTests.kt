package app.cliq.backend.acceptance.auth.oidc

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.params.OidcAuthExchangeParams
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.error.ErrorCode
import app.cliq.backend.oidc.AuthExchangeRepository
import app.cliq.backend.oidc.factory.AuthExchangeFactory
import app.cliq.backend.support.ErrorResponseClient
import app.cliq.backend.support.UserCreationHelper
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper
import java.time.Clock
import java.time.OffsetDateTime

@AcceptanceTest
class AuthExchangeTests(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val authExchangeFactory: AuthExchangeFactory,
    @Autowired
    private val authExchangeRepository: AuthExchangeRepository,
    @Autowired
    private val userCreationHelper: UserCreationHelper,
    @Autowired
    private val clock: Clock,
) : AcceptanceTester() {
    @Test
    fun `test auth exchange creation and retrieval`() {
        val ipAddress = "127.0.0.1"
        val tokenPair = userCreationHelper.createRandomOidcAuthenticatedUser()
        val authExchange =
            authExchangeFactory.create(
                ipAddress = ipAddress,
                session = tokenPair.session,
                jwtToken = tokenPair.jwt.tokenValue,
                refreshToken = tokenPair.refreshToken,
            )

        val exchangeParams = OidcAuthExchangeParams(authExchange.exchangeCode)
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/oidc/exchange")
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
        val response = objectMapper.readValue(content, TokenResponse::class.java)

        assertEquals(tokenPair.session.name, response.name)
        assertEquals(tokenPair.session.id, response.id)
        assertEquals(tokenPair.jwt.tokenValue, response.accessToken)
        assertEquals(tokenPair.refreshToken, response.refreshToken)
        assertNull(tokenPair.session.lastUsedAt)

        val cont = authExchangeRepository.count()
        assertEquals(0, cont)
    }

    @Test
    fun `test cannot exchange from different ip address`() {
        val ipAddress = "127.0.0.1"
        val tokenPair = userCreationHelper.createRandomOidcAuthenticatedUser()
        val authExchange =
            authExchangeFactory.create(
                ipAddress = ipAddress,
                session = tokenPair.session,
                jwtToken = tokenPair.jwt.tokenValue,
                refreshToken = tokenPair.refreshToken,
            )

        val exchangeParams = OidcAuthExchangeParams(authExchange.exchangeCode)
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/oidc/exchange")
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

        val cont = authExchangeRepository.count()
        assertEquals(1, cont)
    }

    @Test
    fun `test cannot exchange with invalid code`() {
        val exchangeParams = OidcAuthExchangeParams("invalid")
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/oidc/exchange")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(exchangeParams)),
                ).andExpect(status().isBadRequest)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val response = objectMapper.readValue(content, ErrorResponseClient::class.java)
        assertEquals(ErrorCode.INVALID_OIDC_AUTH_EXCHANGE_CODE, response.errorCode)
    }

    @Test
    fun `test cannot exchange with expired code`() {
        val ipAddress = "127.0.0.1"
        val tokenPair = userCreationHelper.createRandomOidcAuthenticatedUser()
        val authExchange =
            authExchangeFactory.create(
                ipAddress = ipAddress,
                session = tokenPair.session,
                jwtToken = tokenPair.jwt.tokenValue,
                refreshToken = tokenPair.refreshToken,
            )
        authExchange.expiresAt = OffsetDateTime.now(clock).minusSeconds(1)
        authExchangeRepository.saveAndFlush(authExchange)

        val exchangeParams = OidcAuthExchangeParams(authExchange.exchangeCode)
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/oidc/exchange")
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
        assertEquals(ErrorCode.INVALID_OIDC_AUTH_EXCHANGE_CODE, response.errorCode)

        val cont = authExchangeRepository.count()
        assertEquals(1, cont)
    }
}
