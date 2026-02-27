package app.cliq.backend.acceptance.openapi

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.support.UserCreationHelper
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders

@AcceptanceTest
class OpenApiSecurityTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userCreationHelper: UserCreationHelper,
) : AcceptanceTester() {
    private val successfulOpenApiEndpoints =
        listOf(
            "/api",
            "/api/openapi/scalar",
            "/api/openapi/swagger-ui",
            "/api/openapi",
        )

    @Test
    fun `test openapi endpoints are available for non logged in users`() {
        successfulOpenApiEndpoints.forEach { url ->
            mockMvc
                .perform(MockMvcRequestBuilders.get(url))
                .andExpect {
                    val statusCode = it.response.status
                    assertTrue(statusCode in 200..399, "Expected 2xx or 3xx, got $statusCode for $url")
                }
        }
    }

    @Test
    fun `test openapi endpoints are available for logged in users`() {
        val authenticatedUserData = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair = authenticatedUserData.tokenPair

        successfulOpenApiEndpoints.forEach { url ->
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get(url)
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect {
                    val statusCode = it.response.status
                    assertTrue(statusCode in 200..399, "Expected 2xx or 3xx, got $statusCode for $url")
                }
        }
    }
}
