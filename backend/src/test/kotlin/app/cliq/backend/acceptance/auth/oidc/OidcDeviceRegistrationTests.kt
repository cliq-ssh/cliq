package app.cliq.backend.acceptance.auth.oidc

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.factory.OidcCallbackTokenFactory
import app.cliq.backend.auth.params.DeviceRegistrationParams
import app.cliq.backend.auth.params.OidcCallbackParams
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.auth.view.login.LoginFinishResponse
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.support.UserCreationHelper
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper

@AcceptanceTest
class OidcDeviceRegistrationTests(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val userCreationHelper: UserCreationHelper,
    @Autowired
    private val oidcCallbackTokenFactory: OidcCallbackTokenFactory,
    @Autowired
    private val sessionRepository: SessionRepository,
) : AcceptanceTester() {
    @Test
    fun `exchange with existing oidc session id should result in an rotation`() {
        val sessionId = "SID123"
        val ipAddress = "127.0.0.1"
        val userCreationData =
            userCreationHelper.createRandomOidcAuthenticatedUser(
                oidcSessionId = sessionId,
            )

        // Assert that one session exists
        val sessionCount = sessionRepository.count()
        assertEquals(1, sessionCount)

        val oidcCallbackToken =
            oidcCallbackTokenFactory.create(
                ipAddress,
                userCreationData.session.user,
                sessionId,
            )

        // Perform OIDC callback

        val oidcCallbackParams =
            OidcCallbackParams(
                oidcCallbackToken.token,
            )
        val callbackResult =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/oidc/callback")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(oidcCallbackParams)),
                ).andExpect(status().isOk)
                .andReturn()
        val callbackContent = callbackResult.response.contentAsString
        val loginFinishResponse = objectMapper.readValue(callbackContent, LoginFinishResponse::class.java)

        // Assert that the auth exchange code in the response matches the one from the callback token
        assertEquals(oidcCallbackToken.authExchange.exchangeCode, loginFinishResponse.authExchangeCode)

        // Perform device registration
        val deviceRegistrationParams =
            DeviceRegistrationParams(
                loginFinishResponse.authExchangeCode,
                "",
                "",
                "Test Session",
            )
        val deviceRegistrationResult =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/device/register")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(deviceRegistrationParams)),
                ).andExpect(status().isOk)
                .andReturn()
        val deviceRegistrationContent = deviceRegistrationResult.response.contentAsString
        val tokenResponse = objectMapper.readValue(deviceRegistrationContent, TokenResponse::class.java)

        // Assert that there is still only one session
        val newSessionCount = sessionRepository.count()
        assertEquals(1, newSessionCount)

        // Assert that old jwt does not work
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/me")
                    .header("Authorization", "Bearer ${userCreationData.jwt.tokenValue}"),
            ).andExpect(status().isUnauthorized)

        // Assert that new jwt works
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/me")
                    .header("Authorization", "Bearer ${tokenResponse.accessToken}"),
            ).andExpect(status().isOk)
    }
}
