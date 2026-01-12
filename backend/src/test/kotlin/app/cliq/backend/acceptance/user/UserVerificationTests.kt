package app.cliq.backend.acceptance.user

import app.cliq.backend.acceptance.EmailAcceptanceTest
import app.cliq.backend.acceptance.EmailAcceptanceTester
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.docs.EXAMPLE_EMAIL
import app.cliq.backend.docs.EXAMPLE_PASSWORD
import app.cliq.backend.docs.EXAMPLE_USERNAME
import app.cliq.backend.user.UNVERIFIED_USER_INTERVAL_MINUTES
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.params.ResendVerificationEmailParams
import app.cliq.backend.user.params.VerifyParams
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
class UserVerificationTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val objectMapper: ObjectMapper,
    @Autowired private val userRepository: UserRepository,
) : EmailAcceptanceTester() {
    @Test
    fun `cannot verify with an invalid token`() {
        val email = EXAMPLE_EMAIL
        val password = EXAMPLE_PASSWORD
        val username = EXAMPLE_USERNAME
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
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(registrationParams)),
            ).andExpect(MockMvcResultMatchers.status().isCreated)

        val invalidVerificationToken = "invalid-token"
        val verifyContent = VerifyParams(email, invalidVerificationToken)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/verification")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyContent)),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)

        assertTrue(greenMail.waitForIncomingEmail(10_000, 1))

        val user = userRepository.findByEmail(email)
        assertTrue(user != null)

        assertTrue(user.isEmailVerified().not())
    }

    @Test
    fun `cannot verify twice`() {
        val email = EXAMPLE_EMAIL
        val password = EXAMPLE_PASSWORD
        val username = EXAMPLE_USERNAME
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
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(registrationParams)),
            ).andExpect(MockMvcResultMatchers.status().isCreated)

        assertTrue(greenMail.waitForIncomingEmail(1))

        var user = userRepository.findByEmail(email)
        assertTrue(user != null)

        val verifyContent = VerifyParams(email, user.emailVerificationToken!!)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/verification")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyContent)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/verification")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyContent)),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)

        user = userRepository.findByEmail(email)
        assertTrue(user != null)

        assertTrue(user.isEmailVerified())
        assertTrue(user.emailVerifiedAt != null)
        assertEquals(user.emailVerificationToken, null)
        assertTrue(user.emailVerificationSentAt != null)
    }

    @Test
    fun `cannot verify with an expired token`() {
        val email = EXAMPLE_EMAIL
        val password = EXAMPLE_PASSWORD
        val username = EXAMPLE_USERNAME
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
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(registrationParams)),
            ).andExpect(MockMvcResultMatchers.status().isCreated)

        assertTrue(greenMail.waitForIncomingEmail(1))
        val user = userRepository.findByEmail(email)
        assertNotNull(user)

        // Change the verification token to an expired one
        user.emailVerificationSentAt = user.emailVerificationSentAt!!.minusMinutes(UNVERIFIED_USER_INTERVAL_MINUTES)
        userRepository.save(user)

        // Try to verify with the expired token
        val verifyContent = VerifyParams(email, user.emailVerificationToken!!)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/verification")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyContent)),
            ).andExpect(MockMvcResultMatchers.status().isForbidden)
    }

    @Test
    fun `resend verification email`() {
        // Create User
        val email = EXAMPLE_EMAIL
        val password = EXAMPLE_PASSWORD
        val username = EXAMPLE_USERNAME
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
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(registrationParams)),
            ).andExpect(MockMvcResultMatchers.status().isCreated)

        assertTrue(greenMail.waitForIncomingEmail(1))

        // Resend verification email
        val resendParams = ResendVerificationEmailParams(email)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/verification/resend-email")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resendParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)
        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[1]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())
    }
}
