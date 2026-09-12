package sh.cliq.backend.acceptance.auth.oidc

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import sh.cliq.backend.acceptance.AcceptanceTest
import sh.cliq.backend.acceptance.AcceptanceTester
import sh.cliq.backend.auth.AuthExchangeRepository
import sh.cliq.backend.auth.factory.OidcCallbackTokenFactory
import sh.cliq.backend.auth.params.DeviceRegistrationParams
import sh.cliq.backend.auth.params.OidcCallbackParams
import sh.cliq.backend.auth.view.TokenResponse
import sh.cliq.backend.auth.view.login.LoginFinishResponse
import sh.cliq.backend.error.ErrorCode
import sh.cliq.backend.session.SessionRepository
import sh.cliq.backend.support.ErrorResponseClient
import sh.cliq.backend.support.UserCreationHelper
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
        val userCreationData = userCreationHelper.createRandomOidcUser()
        val callbackToken = oidcCallbackTokenFactory.create(userCreationData.user, null)

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
                        .content(objectMapper.writeValueAsString(callbackParams)),
                ).andExpect(status().isOk)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val loginFinishResponse = objectMapper.readValue(content, LoginFinishResponse::class.java)
        assertEquals(callbackToken.authExchange.exchangeCode, loginFinishResponse.authExchangeCode)
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
        val userCreationData = userCreationHelper.createRandomOidcUser()
        val callbackToken = oidcCallbackTokenFactory.create(userCreationData.user, null)
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
                        .content(objectMapper.writeValueAsString(callbackParams)),
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
        val userCreationData = userCreationHelper.createRandomOidcUser()
        val callbackToken = oidcCallbackTokenFactory.create(userCreationData.user, null)

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
                        .content(objectMapper.writeValueAsString(callbackParams)),
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
                        .content(objectMapper.writeValueAsString(registrationParams)),
                ).andExpect(status().isOk)
                .andReturn()
        val registrationContent = registrationResult.response.contentAsString
        assert(registrationContent.isNotEmpty())
        assertDoesNotThrow { objectMapper.readValue(registrationContent, TokenResponse::class.java) }
    }
}
