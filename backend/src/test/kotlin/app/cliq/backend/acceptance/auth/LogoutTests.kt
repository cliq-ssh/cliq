package app.cliq.backend.acceptance.auth

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.params.RefreshParams
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.support.UserCreationHelper
import app.cliq.backend.utils.TokenUtils
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper

@AcceptanceTest
class LogoutTests(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val sessionRepository: SessionRepository,
    @Autowired
    private val userCreationHelper: UserCreationHelper,
    @Autowired
    private val tokenUtils: TokenUtils,
) : AcceptanceTester() {
    @Test
    fun `test logout`() {
        val authenticatedUserData = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair = authenticatedUserData.tokenPair

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/logout")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(status().isNoContent)

        // test access token is invalid by trying to get the current user information
        mockMvc
            .perform(
                MockMvcRequestBuilders.get("/api/user/me"),
            ).andExpect(status().isUnauthorized)

        // the test refresh token is invalid by trying to refresh the access token
        val refreshParams = RefreshParams(tokenPair.refreshToken)
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/refresh")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(refreshParams)),
            ).andExpect(status().isBadRequest)

        // assert session is deleted
        val hashedRefreshedToken = tokenUtils.hashTokenUsingSha512(tokenPair.refreshToken)
        assert(sessionRepository.findByRefreshToken(hashedRefreshedToken) == null)
    }
}
