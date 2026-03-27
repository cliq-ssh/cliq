package app.cliq.backend.acceptance.user

import app.cliq.backend.acceptance.EmailAcceptanceTest
import app.cliq.backend.acceptance.EmailAcceptanceTester
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.support.UserCreationHelper
import app.cliq.backend.user.KEY_ROTATION_TOKEN_INTERVAL_MINUTES
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.params.StartKeyRotationParams
import app.cliq.backend.user.params.VerifyKeyRotationParams
import app.cliq.backend.vault.VaultRepository
import app.cliq.backend.vault.params.VaultParams
import org.apache.commons.mail2.jakarta.util.MimeMessageParser
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNotNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals
import kotlin.test.assertTrue

@EmailAcceptanceTest
class KeyRotationTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val objectMapper: ObjectMapper,
    @Autowired private val userRepository: UserRepository,
    @Autowired private val sessionRepository: SessionRepository,
    @Autowired private val vaultRepository: VaultRepository,
    @Autowired private val userCreationHelper: UserCreationHelper,
) : EmailAcceptanceTester() {
    @Test
    fun `start key rotation sends email with code`() {
        val creationData = userCreationHelper.createRandomUser()
        val user = creationData.user

        val params = StartKeyRotationParams(user.email)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[0]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())

        val updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.keyRotationToken)
        assertNotNull(updatedUser.keyRotationSentAt)
    }

    @Test
    fun `start key rotation with unverified email fails`() {
        val creationData = userCreationHelper.createRandomUser(verified = false)
        val user = creationData.user

        val params = StartKeyRotationParams(user.email)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)
    }

    @Test
    fun `start key rotation with unknown email returns 204`() {
        val params = StartKeyRotationParams("unknown@example.com")

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        // Should not send any email
        assertTrue(!greenMail.waitForIncomingEmail(1))
    }

    @Test
    fun `verify key rotation with valid code and updates keys`() {
        val creationData = userCreationHelper.createRandomUser()
        val user = creationData.user

        // Start rotation
        val startParams = StartKeyRotationParams(user.email)
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        // Get the code from the database
        var updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        val code = updatedUser.keyRotationToken!!

        // Verify rotation
        val newDataKey = "new-encryption-key-base64"
        val newSrpSalt = "new-srp-salt-base64"
        val newSrpVerifier = "new-srp-verifier-base64"

        val verifyParams = VerifyKeyRotationParams(
            email = user.email,
            code = code,
            dataEncryptionKey = newDataKey,
            srpSalt = newSrpSalt,
            srpVerifier = newSrpVerifier,
            vault = defaultVaultParams(),
        )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/verify")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        // Verify user was updated
        updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        assertEquals(newDataKey, updatedUser.dataEncryptionKey)
        assertEquals(newSrpSalt, updatedUser.srpSalt)
        assertEquals(newSrpVerifier, updatedUser.srpVerifier)
        assertEquals(null, updatedUser.keyRotationToken)

        // Verify vault was updated
        val vault = vaultRepository.getByUser(updatedUser)
        assertNotNull(vault)
        assertEquals(defaultVaultParams().configuration, vault.encryptedConfig)
        assertEquals(defaultVaultParams().version, vault.version)
    }

    @Test
    fun `verify key rotation with invalid code fails`() {
        val creationData = userCreationHelper.createRandomUser()
        val user = creationData.user

        val verifyParams = VerifyKeyRotationParams(
            email = user.email,
            code = "INVALID_CODE",
            dataEncryptionKey = "new-key",
            srpSalt = "new-salt",
            srpVerifier = "new-verifier",
            vault = defaultVaultParams(),
        )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/verify")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyParams)),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)
    }

    @Test
    fun `verify key rotation with expired code fails`() {
        val creationData = userCreationHelper.createRandomUser()
        val user = creationData.user

        // Start rotation
        val startParams = StartKeyRotationParams(user.email)
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        // Get the code from the database
        val updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        val code = updatedUser.keyRotationToken!!

        // Make the code expire
        updatedUser.keyRotationSentAt = updatedUser.keyRotationSentAt!!.minusMinutes(
            KEY_ROTATION_TOKEN_INTERVAL_MINUTES + 1,
        )
        userRepository.save(updatedUser)

        // Try to verify with expired code
        val verifyParams = VerifyKeyRotationParams(
            email = user.email,
            code = code,
            dataEncryptionKey = "new-key",
            srpSalt = "new-salt",
            srpVerifier = "new-verifier",
            vault = defaultVaultParams(),
        )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/verify")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyParams)),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)
    }

    @Test
    fun `verify key rotation logs out all sessions`() {
        val authData = userCreationHelper.createRandomAuthenticatedUser()
        val user = authData.userCreationData.user

        // Verify user has a session
        val sessionCount = sessionRepository.findAll().size
        assertTrue(sessionCount > 0)

        // Start rotation
        val startParams = StartKeyRotationParams(user.email)
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        // Get the code
        val updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        val code = updatedUser.keyRotationToken!!

        // Verify rotation
        val verifyParams = VerifyKeyRotationParams(
            email = user.email,
            code = code,
            dataEncryptionKey = "new-key",
            srpSalt = "new-salt",
            srpVerifier = "new-verifier",
            vault = defaultVaultParams(),
        )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/verify")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        // Verify all sessions were deleted
        val userSessions = sessionRepository.findAll().filter { it.user.id == user.id }
        assertEquals(0, userSessions.size)
    }

    @Test
    fun `verify key rotation for OIDC user without SRP data succeeds`() {
        val creationData = userCreationHelper.createRandomOidcUser()
        val user = creationData.user

        // Start rotation
        val startParams = StartKeyRotationParams(user.email)
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        // Get the code
        var updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        val code = updatedUser.keyRotationToken!!

        val oldSrpSalt = updatedUser.srpSalt
        val oldSrpVerifier = updatedUser.srpVerifier

        // Verify rotation with only data encryption key (no SRP for OIDC)
        val verifyParams = VerifyKeyRotationParams(
            email = user.email,
            code = code,
            dataEncryptionKey = "new-key-oidc",
            srpSalt = null,
            srpVerifier = null,
            vault = defaultVaultParams(),
        )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/verify")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        // Verify only data key was updated, SRP was not changed
        updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        assertEquals("new-key-oidc", updatedUser.dataEncryptionKey)
        assertEquals(oldSrpSalt, updatedUser.srpSalt)
        assertEquals(oldSrpVerifier, updatedUser.srpVerifier)

        // Verify vault updates
        val vault = vaultRepository.getByUser(updatedUser)
        assertNotNull(vault)
        assertEquals(defaultVaultParams().configuration, vault.encryptedConfig)
        assertEquals(defaultVaultParams().version, vault.version)
    }

    @Test
    fun `resend key rotation code`() {
        val creationData = userCreationHelper.createRandomUser()
        val user = creationData.user

        // First rotation
        val startParams = StartKeyRotationParams(user.email)
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        var updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        val oldCode = updatedUser.keyRotationToken

        // Resend
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/key-rotation/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(2))

        updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)

        // Code should have changed
        assertTrue(updatedUser.keyRotationToken != oldCode)
    }

    private fun defaultVaultParams(): VaultParams = VaultParams(
        configuration = "encrypted-vault-config",
        version = "2",
    )
}
