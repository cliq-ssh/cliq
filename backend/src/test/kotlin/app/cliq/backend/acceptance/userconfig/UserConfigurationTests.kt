package app.cliq.backend.acceptance.userconfig

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.support.UserCreationHelper
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers
import tools.jackson.databind.ObjectMapper

@AcceptanceTest
class UserConfigurationTests(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val userCreationHelper: UserCreationHelper,
    @Autowired
    private val objectMapper: ObjectMapper,
) : AcceptanceTester() {
    @Test
    fun `test endpoints cannot be accessed without authentication`() {
        mockMvc
            .perform(
                MockMvcRequestBuilders.put("/api/user/configuration"),
            ).andExpect(MockMvcResultMatchers.status().isUnauthorized)

        mockMvc
            .perform(
                MockMvcRequestBuilders.get("/api/user/configuration"),
            ).andExpect(MockMvcResultMatchers.status().isUnauthorized)

        mockMvc
            .perform(
                MockMvcRequestBuilders.get("/api/user/configuration/last-updated"),
            ).andExpect(MockMvcResultMatchers.status().isUnauthorized)
    }

    @Test
    fun `test endpoints can be accessed wit authentication`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/user/configuration")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/configuration")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isNotFound)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/configuration/last-updated")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isOk)
    }

    @Test
    fun `test create and retrieve user configuration`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()


        val payload =
            mapOf(
                "configuration" to "testConfig",
            )

        // Create configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/user/configuration")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(payload)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/configuration")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isOk)
            .andExpect { result ->
                val content = result.response.contentAsString
                assert(content.contains("testConfig"))
            }
    }

    @Test
    fun `test last updated`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()

        val payload =
            mapOf(
                "configuration" to "testConfig",
            )

        // Create configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/user/configuration")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(payload)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve configuration
        val response =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/user/configuration")
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andReturn()

        val responseString = response.response.contentAsString
        assert(responseString.isNotEmpty())
        val configJson = objectMapper.readTree(responseString)
        val configUpdatedAt = configJson.get("updatedAt").asString()

        // Check last updated time
        val result = mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/configuration/last-updated")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isOk)
            .andReturn()
        val content = result.response.contentAsString
        assert(content == configUpdatedAt)
    }

    @Test
    fun `test update user configuration`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()

        val initialPayload =
            mapOf(
                "configuration" to "initialConfig",
            )

        // Create initial configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/user/configuration")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(initialPayload)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve initial configuration

        val secondResponse =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/user/configuration")
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andExpect { result ->
                    val content = result.response.contentAsString
                    assert(content.contains("initialConfig"))
                }.andReturn()

        val responseString = secondResponse.response.contentAsString
        assert(responseString.isNotEmpty())
        val initialConfigJson = objectMapper.readTree(responseString)
        val initialConfigUpdatedAt = initialConfigJson.get("updatedAt").asString()

        // Check last updated time
        val result = mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/configuration/last-updated")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isOk)
            .andReturn()
        val content = result.response.contentAsString
        assert(content == initialConfigUpdatedAt)

        // Update configuration
        val updatedPayload =
            mapOf(
                "configuration" to "updatedConfig",
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/user/configuration")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(updatedPayload)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve updated configuration
        val response =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/user/configuration")
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andExpect { result ->
                    val content = result.response.contentAsString
                    assert(content.contains("updatedConfig"))
                }.andReturn()

        val updatedResponseString = response.response.contentAsString
        assert(updatedResponseString.isNotEmpty())
        val updatedConfigJson = objectMapper.readTree(updatedResponseString)
        val updatedConfigUpdatedAt = updatedConfigJson.get("updatedAt").asString()

        // Check last updated time after update
        val lastUpdatedResult = mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/user/configuration/last-updated")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isOk)
            .andReturn()
        val lastUpdatedContent = lastUpdatedResult.response.contentAsString
        assert(lastUpdatedContent == updatedConfigUpdatedAt)
    }
}
