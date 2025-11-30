package app.cliq.backend.user

import app.cliq.backend.AcceptanceTest
import app.cliq.backend.AcceptanceTester
import tools.jackson.databind.ObjectMapper
import org.apache.commons.mail2.jakarta.util.MimeMessageParser
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import kotlin.test.assertContains
import kotlin.test.assertEquals
import kotlin.test.assertTrue

@AcceptanceTest
class UserRegistrationAcceptanceTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userRepository: UserRepository,
    @Autowired private val objectMapper: ObjectMapper,
) : AcceptanceTester() {
    @Test
    fun `user can register and verify email`() {
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

        val emailMessages = greenMail.receivedMessages[0]
        val parser = MimeMessageParser(emailMessages).parse()

        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())

        var user = userRepository.findUserByEmail(email)
        assertTrue(user != null)

        assertTrue(user.emailVerificationToken != null)
        assertEquals(user.emailVerifiedAt, null)
        assertTrue(user.emailVerificationSentAt != null)

        assertContains(parser.htmlContent, user.emailVerificationToken!!)
        assertContains(parser.plainContent, user.emailVerificationToken!!)

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

        user = userRepository.findUserByEmail(email)
        assertTrue(user != null)

        assertTrue(user.isEmailVerified())
        assertTrue(user.emailVerifiedAt != null)
        assertEquals(user.emailVerificationToken, null)
    }

    @Test
    fun `cannot register twice with the same email`() {
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
                MockMvcRequestBuilders
                    .post("/api/v1/user/register")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(userDetails)),
            ).andExpect(status().isBadRequest)

        assertTrue(greenMail.waitForIncomingEmail(1))
    }
}
