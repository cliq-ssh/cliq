package app.cliq.backend.acceptance.auth

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.params.LoginParams
import app.cliq.backend.auth.params.RefreshParams
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.docs.EXAMPLE_EMAIL
import app.cliq.backend.docs.EXAMPLE_PASSWORD
import app.cliq.backend.docs.EXAMPLE_USERNAME
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper

@AcceptanceTest
class CompleteUserFlowTest(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val objectMapper: ObjectMapper
) : AcceptanceTester() {
    @Test
    fun `test user registration, login, refresh and logout`() {
        val email = EXAMPLE_EMAIL
        val password = EXAMPLE_PASSWORD
        val username = EXAMPLE_USERNAME

        // Registration
        val registrationParams =
            RegistrationParams(
                email = email,
                password = password,
                username = username,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/register")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(registrationParams)),
            ).andExpect(status().isCreated)

        // Login
        val sessionName = "Test Session"
        val loginParams =
            LoginParams(
                email = EXAMPLE_EMAIL,
                password = EXAMPLE_PASSWORD,
                name = sessionName,
            )

        val loginResult = mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/login")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(loginParams)),
            ).andExpect(status().isOk)
            .andReturn()
        val loginContent = loginResult.response.contentAsString
        val loginResponse = objectMapper.readValue(loginContent, TokenResponse::class.java)

        // Test login by getting self the user information
        mockMvc.perform(
            MockMvcRequestBuilders.get("/api/user/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer ${loginResponse.accessToken}")
        ).andExpect(status().isOk)

        // Refresh
        val refreshParams = RefreshParams(loginResponse.refreshToken)
        val refreshResult = mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/refresh")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(refreshParams)),
            ).andExpect(status().isOk)
            .andReturn()
        val refreshContent = refreshResult.response.contentAsString
        val refreshResponse = objectMapper.readValue(refreshContent, TokenResponse::class.java)

        // Test login with the new access token by getting self the user information
        mockMvc.perform(
            MockMvcRequestBuilders.get("/api/user/me")
                .header(HttpHeaders.AUTHORIZATION, "Bearer ${refreshResponse.accessToken}")
        ).andExpect(status().isOk)

        // logout
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/logout")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer ${refreshResponse.accessToken}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(refreshParams)),
            ).andExpect(status().isOk)
    }
}
