package app.cliq.backend.acceptance.vault

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.support.UserCreationHelper
import app.cliq.backend.vault.params.VaultParams
import app.cliq.backend.vault.view.VaultView
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals

@AcceptanceTest
class VaultDataTests(
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
                MockMvcRequestBuilders.put("/api/vault"),
            ).andExpect(MockMvcResultMatchers.status().isUnauthorized)

        mockMvc
            .perform(
                MockMvcRequestBuilders.get("/api/vault"),
            ).andExpect(MockMvcResultMatchers.status().isUnauthorized)

        mockMvc
            .perform(
                MockMvcRequestBuilders.get("/api/vault/last-updated"),
            ).andExpect(MockMvcResultMatchers.status().isUnauthorized)
    }

    @Test
    fun `test endpoints can be accessed with authentication`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vault")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/vault")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isNotFound)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/vault/last-updated")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isOk)
    }

    @Test
    fun `test create and retrieve user configuration`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()

        val params = VaultParams(configuration = "testConfig", version = "1")

        // Create configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vault")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/vault")
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

        val params = VaultParams(configuration = "testConfig", version = "1")

        // Create configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vault")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve configuration
        val response =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/vault")
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andReturn()

        val responseString = response.response.contentAsString
        assert(responseString.isNotEmpty())
        val vaultView = objectMapper.readValue(responseString, VaultView::class.java)
        val configurationUpdatedAt = vaultView.updatedAt.toString()

        // Check last updated time
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/vault/last-updated")
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andReturn()

        val content = result.response.contentAsString
        assertEquals(configurationUpdatedAt, content)
    }

    @Test
    fun `test update user configuration`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()

        val initialParams = VaultParams(configuration = "initialConfig", version = "1")

        // Create initial configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vault")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(initialParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve initial configuration

        val secondResponse =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/vault")
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andExpect { result ->
                    val content = result.response.contentAsString
                    assert(content.contains("initialConfig"))
                }.andReturn()

        val responseString = secondResponse.response.contentAsString
        assert(responseString.isNotEmpty())
        val vaultView = objectMapper.readValue(responseString, VaultView::class.java)
        val initialConfigUpdatedAt = vaultView.updatedAt.toString()

        // Check last updated time
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/vault/last-updated")
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andReturn()
        val content = result.response.contentAsString
        assert(content == initialConfigUpdatedAt)

        // Update configuration
        val updatedParams = VaultParams(configuration = "updatedConfig", version = "2")

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vault")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(updatedParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve updated configuration
        val response =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/vault")
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andExpect { result ->
                    val content = result.response.contentAsString
                    assert(content.contains("updatedConfig"))
                }.andReturn()

        val updatedResponseString = response.response.contentAsString
        assert(updatedResponseString.isNotEmpty())
        val updatedConfigView = objectMapper.readValue(updatedResponseString, VaultView::class.java)
        val updatedConfigUpdatedAt = updatedConfigView.updatedAt.toString()

        // Check last updated time after update
        val lastUpdatedResult =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/vault/last-updated")
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andReturn()
        val lastUpdatedContent = lastUpdatedResult.response.contentAsString
        assert(lastUpdatedContent == updatedConfigUpdatedAt)
    }
}
