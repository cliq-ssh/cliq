package app.cliq.backend.userconfig

import app.cliq.backend.AcceptanceTest
import app.cliq.backend.AcceptanceTester
import app.cliq.backend.support.UserHelper
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper

@AcceptanceTest
class UserConfigurationAcceptanceTests(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val userHelper: UserHelper,
    @Autowired
    private val objectMapper: ObjectMapper,
) : AcceptanceTester() {
    @Test
    fun `test endpoints cannot be accessed without authentication`() {
        mockMvc
            .perform(
                MockMvcRequestBuilders.put("/api/v1/user/configuration"),
            ).andExpect(status().isUnauthorized)

        mockMvc
            .perform(
                MockMvcRequestBuilders.get("/api/v1/user/configuration"),
            ).andExpect(status().isUnauthorized)

        mockMvc
            .perform(
                MockMvcRequestBuilders.get("/api/v1/user/configuration/last-updated"),
            ).andExpect(status().isUnauthorized)
    }

    @Test
    fun `test endpoints can be accessed wit authentication`() {
        val session = userHelper.createRandomAuthenticatedUser()

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/v1/user/configuration")
                    .header("Authorization", "Bearer ${session.apiKey}"),
            ).andExpect(status().isBadRequest)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/v1/user/configuration")
                    .header("Authorization", "Bearer ${session.apiKey}"),
            ).andExpect(status().isNotFound)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/v1/user/configuration/last-updated")
                    .header("Authorization", "Bearer ${session.apiKey}"),
            ).andExpect(status().isOk)
    }

    @Test
    fun `test create and retrieve user configuration`() {
        val session = userHelper.createRandomAuthenticatedUser()

        val payload =
            mapOf(
                "configuration" to "testConfig",
            )

        // Create configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/v1/user/configuration")
                    .header("Authorization", "Bearer ${session.apiKey}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(payload)),
            ).andExpect(status().isOk)

        // Retrieve configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/v1/user/configuration")
                    .header("Authorization", "Bearer ${session.apiKey}"),
            ).andExpect(status().isOk)
            .andExpect { result ->
                val content = result.response.contentAsString
                assert(content.contains("testConfig"))
            }
    }

    @Test
    fun `test last updated`() {
        val session = userHelper.createRandomAuthenticatedUser()

        val payload =
            mapOf(
                "configuration" to "testConfig",
            )

        // Create configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/v1/user/configuration")
                    .header("Authorization", "Bearer ${session.apiKey}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(payload)),
            ).andExpect(status().isOk)

        // Retrieve configuration
        val response =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/v1/user/configuration")
                        .header("Authorization", "Bearer ${session.apiKey}"),
                ).andExpect(status().isOk)
                .andReturn()

        val responseString = response.response.contentAsString
        assert(responseString.isNotEmpty())
        val configJson = objectMapper.readTree(responseString)
        val configUpdatedAt = configJson.get("updatedAt").asText()

        // Check last updated time
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/v1/user/configuration/last-updated")
                    .header("Authorization", "Bearer ${session.apiKey}"),
            ).andExpect(status().isOk)
            .andExpect { it.toString() == configUpdatedAt }
    }

    @Test
    fun `test update user configuration`() {
        val session = userHelper.createRandomAuthenticatedUser()

        val initialPayload =
            mapOf(
                "configuration" to "initialConfig",
            )

        // Create initial configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/v1/user/configuration")
                    .header("Authorization", "Bearer ${session.apiKey}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(initialPayload)),
            ).andExpect(status().isOk)

        // Retrieve initial configuration

        val secondResponse =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/v1/user/configuration")
                        .header("Authorization", "Bearer ${session.apiKey}"),
                ).andExpect(status().isOk)
                .andExpect { result ->
                    val content = result.response.contentAsString
                    assert(content.contains("initialConfig"))
                }.andReturn()

        val responseString = secondResponse.response.contentAsString
        assert(responseString.isNotEmpty())
        val initialConfigJson = objectMapper.readTree(responseString)
        val initialConfigUpdatedAt = initialConfigJson.get("updatedAt").asText()

        // Check last updated time
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/v1/user/configuration/last-updated")
                    .header("Authorization", "Bearer ${session.apiKey}"),
            ).andExpect(status().isOk)
            .andExpect { it.toString() == initialConfigUpdatedAt }

        // Update configuration
        val updatedPayload =
            mapOf(
                "configuration" to "updatedConfig",
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/v1/user/configuration")
                    .header("Authorization", "Bearer ${session.apiKey}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(updatedPayload)),
            ).andExpect(status().isOk)

        // Retrieve updated configuration
        val response =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/v1/user/configuration")
                        .header("Authorization", "Bearer ${session.apiKey}"),
                ).andExpect(status().isOk)
                .andExpect { result ->
                    val content = result.response.contentAsString
                    assert(content.contains("updatedConfig"))
                }.andReturn()

        val updatedResponseString = response.response.contentAsString
        assert(updatedResponseString.isNotEmpty())
        val updatedConfigJson = objectMapper.readTree(updatedResponseString)
        val updatedConfigUpdatedAt = updatedConfigJson.get("updatedAt").asText()

        // Check last updated time after update
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/v1/user/configuration/last-updated")
                    .header("Authorization", "Bearer ${session.apiKey}"),
            ).andExpect(status().isOk)
            .andExpect { it.toString() == updatedConfigUpdatedAt }
    }
}
