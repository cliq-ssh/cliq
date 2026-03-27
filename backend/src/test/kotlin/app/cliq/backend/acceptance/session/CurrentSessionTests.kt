package app.cliq.backend.acceptance.session

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.session.view.SessionResponse
import app.cliq.backend.support.UserCreationHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper

const val CURRENT_SESSION_ENDPOINT = "/api/session/current"

@AcceptanceTest
class CurrentSessionTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userCreationHelper: UserCreationHelper,
    @Autowired private val objectMapper: ObjectMapper,
) : AcceptanceTester() {
    @Test
    fun `test current session endpoint is secured`() {
        mockMvc
            .perform(
                MockMvcRequestBuilders.get(CURRENT_SESSION_ENDPOINT),
            ).andExpect(status().isUnauthorized)
    }

    @Test
    fun `test current session endpoint returns current session`() {
        val authenticatedUserData = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair = authenticatedUserData.tokenPair

        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get(CURRENT_SESSION_ENDPOINT)
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(status().isOk)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        assertDoesNotThrow {
            objectMapper.readValue(content, SessionResponse::class.java)
        }
    }
}
