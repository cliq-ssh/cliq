package sh.cliq.backend.acceptance.vault

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.junit.jupiter.api.assertThrows
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers
import sh.cliq.backend.acceptance.AcceptanceTest
import sh.cliq.backend.acceptance.AcceptanceTester
import sh.cliq.backend.support.UserCreationHelper
import sh.cliq.backend.vault.params.VaultParams
import sh.cliq.backend.vault.view.VaultListView
import sh.cliq.backend.vault.view.VaultView
import tools.jackson.databind.ObjectMapper
import tools.jackson.databind.exc.MismatchedInputException
import java.util.UUID
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
        val uuid = UUID.fromString("01a17506-fcb5-72ef-a3c4-3d8c0b49d5cf")
        val vaultParams = VaultParams(configuration = "testConfig", version = "1")

        // create test vault
        val authenticatedUserData = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair = authenticatedUserData.tokenPair

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vaults/{id}", uuid)
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(vaultParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        val listResponseAuthenticated = mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/vaults")
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isOk)
            .andReturn()
        assertDoesNotThrow {
            objectMapper.readValue(listResponseAuthenticated.response.contentAsString, Array<VaultListView>::class.java)
        }

        val vaultResponseAuthenticated = mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/vaults/{id}", uuid)
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isOk)
            .andReturn()
        assertDoesNotThrow {
            objectMapper.readValue(vaultResponseAuthenticated.response.contentAsString, VaultView::class.java)
        }

        // test unauthenticated cannot access vaults

        mockMvc
            .perform(
                MockMvcRequestBuilders.put("/api/vaults/{id}", uuid)
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(vaultParams)),
            ).andExpect(MockMvcResultMatchers.status().isUnauthorized)

        val listResponse = mockMvc
            .perform(
                MockMvcRequestBuilders.get("/api/vaults"),
            ).andExpect(MockMvcResultMatchers.status().isUnauthorized)
            .andReturn()
        assertThrows<MismatchedInputException> {
            objectMapper.readValue(listResponse.response.contentAsString, Array<VaultListView>::class.java)
        }

        val vaultResponse = mockMvc
            .perform(
                MockMvcRequestBuilders.get("/api/vaults/{id}", uuid),
            ).andExpect(MockMvcResultMatchers.status().isUnauthorized)
            .andReturn()
        assertThrows<MismatchedInputException> {
            objectMapper.readValue(vaultResponse.response.contentAsString, VaultView::class.java)
        }

        mockMvc
            .perform(
                MockMvcRequestBuilders.get("/api/vaults/{id}/last-updated", uuid),
            ).andExpect(MockMvcResultMatchers.status().isUnauthorized)
    }

    @Test
    fun `test create and retrieve user configuration`() {
        val authenticatedUserData = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair = authenticatedUserData.tokenPair

        val params = VaultParams(configuration = "testConfig", version = "1")
        val uuid = UUID.fromString("01a17511-1c89-762d-a5d8-b08ab25c9ec2")

        // Create configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vaults/{id}", uuid)
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/vaults/{id}", uuid)
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isOk)
            .andExpect { result ->
                val content = result.response.contentAsString
                assert(content.contains("testConfig"))
            }
    }

    @Test
    fun `test last updated`() {
        val authenticatedUserData = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair = authenticatedUserData.tokenPair

        val params = VaultParams(configuration = "testConfig", version = "1")
        val uuid = UUID.fromString("01a17511-1c89-762d-a5d8-b08ab25c9ec2")

        // Create configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vaults/{id}", uuid)
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve configuration
        val response =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/vaults/{id}", uuid)
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
                        .get("/api/vaults/{id}/last-updated", uuid)
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andReturn()

        val content = result.response.contentAsString
        assertEquals(configurationUpdatedAt, content)
    }

    @Test
    fun `test update user configuration`() {
        val authenticatedUserData = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair = authenticatedUserData.tokenPair

        val initialParams = VaultParams(configuration = "initialConfig", version = "1")
        val uuid = UUID.fromString("01a17511-1c89-762d-a5d8-b08ab25c9ec2")

        // Create initial configuration
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vaults/{id}", uuid)
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(initialParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve initial configuration

        val secondResponse =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/vaults/{id}", uuid)
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
                        .get("/api/vaults/{id}/last-updated", uuid)
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
                    .put("/api/vaults/{id}", uuid)
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(updatedParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve updated configuration
        val response =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/vaults/{id}", uuid)
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
                        .get("/api/vaults/{id}/last-updated", uuid)
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andReturn()
        val lastUpdatedContent = lastUpdatedResult.response.contentAsString
        assert(lastUpdatedContent == updatedConfigUpdatedAt)
    }

    @Test
    fun `test can create multiple vaults`() {
        val authenticatedUserData = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair = authenticatedUserData.tokenPair

        // Create first vault
        val vault1Params = VaultParams(configuration = "vault1", version = "1")
        val vault1Uuid = UUID.fromString("01a17511-1c89-762d-a5d8-b08ab25c9ec2")

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vaults/{id}", vault1Uuid)
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(vault1Params)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Create first vault
        val vault2Params = VaultParams(configuration = "vault2", version = "1")
        val vault2Uuid = UUID.fromString("01a17513-e07d-7210-946b-7e050b1e0276")

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vaults/{id}", vault2Uuid)
                    .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(vault2Params)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Retrieve list of vaults
        val listResponse =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .get("/api/vaults")
                        .header("Authorization", "Bearer ${tokenPair.jwt.tokenValue}"),
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andReturn()
        val listResponseString = listResponse.response.contentAsString
        assert(listResponseString.isNotEmpty())
        val vaultList = objectMapper.readValue(listResponseString, Array<VaultListView>::class.java)
        assertEquals(2, vaultList.size)
        assert(vaultList.any { it.id == vault1Uuid })
        assert(vaultList.any { it.id == vault2Uuid })
    }

    @Test
    fun `test users cannot access each other vaults`() {
        val authenticatedUser1Data = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair1 = authenticatedUser1Data.tokenPair

        val authenticatedUser2Data = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair2 = authenticatedUser2Data.tokenPair

        // Create vault for user 1
        val vaultParams = VaultParams(configuration = "user1Vault", version = "1")
        val vaultUuid = UUID.fromString("01a17511-1c89-762d-a5d8-b08ab25c9ec2")

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vaults/{id}", vaultUuid)
                    .header("Authorization", "Bearer ${tokenPair1.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(vaultParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // User 2 tries to access user 1's vault
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .get("/api/vaults/{id}", vaultUuid)
                    .header("Authorization", "Bearer ${tokenPair2.jwt.tokenValue}"),
            ).andExpect(MockMvcResultMatchers.status().isForbidden)

        // USer 2 tries to update user 1's vault
        val updatedParams = VaultParams(configuration = "user2Vault", version = "2")
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vaults/{id}", vaultUuid)
                    .header("Authorization", "Bearer ${tokenPair2.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(updatedParams)),
            ).andExpect(MockMvcResultMatchers.status().isForbidden)
    }

    @Test
    fun `test two users tries to create vault with same id`() {
        val authenticatedUser1Data = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair1 = authenticatedUser1Data.tokenPair

        val authenticatedUser2Data = userCreationHelper.createRandomAuthenticatedUser()
        val tokenPair2 = authenticatedUser2Data.tokenPair

        // Create vault for user 1
        val vaultParams = VaultParams(configuration = "user1Vault", version = "1")
        val vaultUuid = UUID.fromString("01a17511-1c89-762d-a5d8-b08ab25c9ec2")

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vaults/{id}", vaultUuid)
                    .header("Authorization", "Bearer ${tokenPair1.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(vaultParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // User 2 tries to create vault with same id
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .put("/api/vaults/{id}", vaultUuid)
                    .header("Authorization", "Bearer ${tokenPair2.jwt.tokenValue}")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(vaultParams)),
            ).andExpect(MockMvcResultMatchers.status().isForbidden)
    }
}
