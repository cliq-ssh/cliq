package app.cliq.backend.user

import app.cliq.backend.AcceptanceTest
import app.cliq.backend.AcceptanceTester
import tools.jackson.databind.ObjectMapper
import org.apache.commons.mail2.jakarta.util.MimeMessageParser
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNotNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import kotlin.test.assertEquals
import kotlin.test.assertTrue

@AcceptanceTest
class UserVerificationAcceptanceTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val objectMapper: ObjectMapper,
    @Autowired private val userRepository: UserRepository,
) : AcceptanceTester() {
    @Test
    fun `cannot verify with an invalid token`() {
        val email = "test@example.lan"
        val userDetails =
            mapOf(
                "email" to email,
                "password" to "SecurePassword123",
                "username" to "testuser",
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/register")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(userDetails)),
            ).andExpect(status().isCreated)

        mockMvc
            .perform(
                MockMvcRequestBuilders.get("/api/v1/user/verification/{token}", "invalid-token"),
            ).andExpect(status().isNotFound)

        assertTrue(greenMail.waitForIncomingEmail(10_000, 1))

        val user = userRepository.findUserByEmail(email)
        assertTrue(user != null)

        assertTrue(user.isEmailVerified().not())
    }

    @Test
    fun `cannot verify twice`() {
        val email = "test@example.lan"
        val userDetails =
            mapOf(
                "email" to email,
                "password" to "SecurePassword123",
                "username" to "testuser",
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/register")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(userDetails)),
            ).andExpect(status().isCreated)

        assertTrue(greenMail.waitForIncomingEmail(1))

        var user = userRepository.findUserByEmail(email)
        assertTrue(user != null)

        val verifyContent =
            mapOf(
                "email" to email,
                "verificationToken" to user.emailVerificationToken,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/verification")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyContent)),
            ).andExpect(status().isOk)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/verification")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyContent)),
            ).andExpect(status().isBadRequest)

        user = userRepository.findUserByEmail(email)
        assertTrue(user != null)

        assertTrue(user.isEmailVerified())
        assertTrue(user.emailVerifiedAt != null)
        assertEquals(user.emailVerificationToken, null)
        assertTrue(user.emailVerificationSentAt != null)
    }

    @Test
    fun `cannot verify with an expired token`() {
        // Create User
        val email = "test@example.lan"

        val userDetails =
            mapOf(
                "email" to email,
                "password" to "SecurePassword123",
                "username" to "testuser",
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/register")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(userDetails)),
            ).andExpect(status().isCreated)

        assertTrue(greenMail.waitForIncomingEmail(1))
        val user = userRepository.findUserByEmail(email)
        assertNotNull(user)

        // Change the verification token to an expired one
        user.emailVerificationSentAt = user.emailVerificationSentAt!!.minusMinutes(UNVERIFIED_USER_INTERVAL_MINUTES)
        userRepository.save(user)

        // Try to verify with the expired token
        val verifyContent =
            mapOf(
                "email" to email,
                "verificationToken" to user.emailVerificationToken,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/verification")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyContent)),
            ).andExpect(status().isForbidden)
    }

    @Test
    fun `resend verification email`() {
        // Create User
        val email = "test@example.lan"

        val userDetails =
            mapOf(
                "email" to email,
                "password" to "SecurePassword123",
                "username" to "testuser",
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/register")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(userDetails)),
            ).andExpect(status().isCreated)

        assertTrue(greenMail.waitForIncomingEmail(1))

        // Resend verification email
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/verification/resend-email")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(mapOf("email" to email))),
            ).andExpect(status().isNoContent)
        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[1]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())
    }
}
