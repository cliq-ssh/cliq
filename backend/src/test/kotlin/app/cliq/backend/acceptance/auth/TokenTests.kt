package app.cliq.backend.acceptance.auth

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.params.RefreshParams
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

@AcceptanceTest
class TokenTests(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val sessionRepository: SessionRepository,
    @Autowired
    private val userCreationHelper: UserCreationHelper
) : AcceptanceTester() {
    @Test
    fun `test token refresh`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()

        // refresh
        val refreshParams = RefreshParams(tokenPair.refreshToken)
        val result = mockMvc.perform(
            MockMvcRequestBuilders.post("/api/auth/refresh")
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(objectMapper.writeValueAsString(refreshParams))
        ).andExpect(status().isOk)
            .andReturn()

        val content = result.response.contentAsString
        val response = objectMapper.readValue(content, TokenResponse::class.java)

        // Old session does not exist
        val oldSession = sessionRepository.findByRefreshToken(tokenPair.refreshToken)
        assertNull(oldSession)

        // New session exists
        val newSession = sessionRepository.findById(response.id)
        assertNotNull(newSession)

        // Can log in with the new access token
        mockMvc.perform(
            MockMvcRequestBuilders.get("/api/user/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer ${response.accessToken}")
        ).andExpect(status().isOk)
    }
}
