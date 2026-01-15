package app.cliq.backend.acceptance.auth

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.params.RefreshParams
import app.cliq.backend.auth.service.JwtResolver
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.support.UserCreationHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNotNull
import org.junit.jupiter.api.assertNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper
import java.time.Clock
import java.time.OffsetDateTime

@AcceptanceTest
class TokenTests(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val sessionRepository: SessionRepository,
    @Autowired
    private val jwtResolver: JwtResolver,
    @Autowired
    private val userCreationHelper: UserCreationHelper,
    @Autowired
    private val clock: Clock,
) : AcceptanceTester() {
    @Test
    fun `test token refresh`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()

        // refresh
        val refreshParams = RefreshParams(tokenPair.refreshToken)

        // find session
        val session = jwtResolver.resolveSessionFromRefreshToken(refreshParams.refreshToken)
        assertNotNull(session)

        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/refresh")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(refreshParams)),
                ).andExpect(status().isOk)
                .andReturn()

        val content = result.response.contentAsString
        val response = objectMapper.readValue(content, TokenResponse::class.java)

        // Old session does not exist
        val oldSession = jwtResolver.resolveSessionFromRefreshToken(refreshParams.refreshToken)
        assertNull(oldSession)

        // New session exists
        val newSession = sessionRepository.findById(response.id)
        assertNotNull(newSession)

        // Can log in with the new access token
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/me")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer ${response.accessToken}"),
            ).andExpect(status().isOk)
    }

    @Test
    fun `cannot refresh with old token`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()
        val refreshParams = RefreshParams(tokenPair.refreshToken)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/refresh")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(refreshParams)),
            ).andExpect(status().isOk)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/refresh")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(refreshParams)),
            ).andExpect(status().isBadRequest)
    }

    @Test
    fun `cannot refresh with invalid token`() {
        val refreshParams = RefreshParams("invalid-token")

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/refresh")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(refreshParams)),
            ).andExpect(status().isBadRequest)
    }

    @Test
    fun `cannot refresh with expired token`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()
        val refreshParams = RefreshParams(tokenPair.refreshToken)

        val session = jwtResolver.resolveSessionFromRefreshToken(refreshParams.refreshToken)
        assertNotNull(session)
        session.expiresAt = OffsetDateTime.now(clock).minusSeconds(1)
        sessionRepository.save(session)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/refresh")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(refreshParams)),
            ).andExpect(status().isBadRequest)
    }
}
