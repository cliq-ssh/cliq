package app.cliq.backend.acceptance.user

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.acceptance.helper.UserHelper
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.user.PASSWORD_RESET_TOKEN_INTERVAL_MINUTES
import app.cliq.backend.user.UNVERIFIED_USER_INTERVAL_MINUTES
import app.cliq.backend.user.UserRepository
import com.fasterxml.jackson.databind.ObjectMapper
import org.apache.commons.mail2.jakarta.util.MimeMessageParser
import org.awaitility.kotlin.await
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNotNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import java.time.Duration
import kotlin.test.assertContains
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue

@AcceptanceTest
class UserRegistrationTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userRepository: UserRepository,
    @Autowired private val sessionRepository: SessionRepository,
    @Autowired private val objectMapper: ObjectMapper,
    @Autowired private val userHelper: UserHelper,
) : AcceptanceTester() {
    @Test
    fun `user can register`() {
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
                    .post("/api/v1/user/verify")
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
                MockMvcRequestBuilders.get("/api/v1/user/verify/{token}", "invalid-token"),
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
                    .post("/api/v1/user/verify")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(verifyContent)),
            ).andExpect(status().isOk)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/verify")
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
                    .post("/api/v1/user/verify")
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
                    .post("/api/v1/user/resend-verification-email")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(mapOf("email" to email))),
            ).andExpect(status().isNoContent)
        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[1]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())
    }

    @Test
    fun `reset password`() {
        val user = userHelper.createRandomVerifiedUser()

        val startResetProcessParams =
            mapOf(
                "email" to user.email,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/init-reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startResetProcessParams)),
            ).andExpect(status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[0]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())

        var updatedUser = userRepository.findUserByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)

        val newPassword = "Password123!!!"
        val resetPasswordParams =
            mapOf(
                "email" to user.email,
                "resetToken" to updatedUser.resetToken!!,
                "password" to newPassword,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParams)),
            ).andExpect(status().isOk)

        updatedUser = userRepository.findUserByEmail(user.email)

        assertNotNull(updatedUser)
        assertEquals(updatedUser.resetToken, null)
        assertEquals(updatedUser.resetSentAt, null)

        val loginParams =
            mapOf(
                "email" to user.email,
                "password" to newPassword,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/session")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(loginParams)),
            ).andExpect(status().isCreated)
    }

    @Test
    fun `reset password deletes all sessions`() {
        var session = userHelper.createRandomAuthenticatedUser()
        session = sessionRepository.findById(session.id).orElseThrow()
        val user = userRepository.findById(session.user.id).orElseThrow()

        val sessions = sessionRepository.findByUserId(user.id)
        assertEquals(1, sessions.size)

        val startResetProcessParams =
            mapOf(
                "email" to user.email,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/init-reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startResetProcessParams)),
            ).andExpect(status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[0]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())

        val updatedUser = userRepository.findUserByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)

        val newPassword = "Password123!!!"
        val resetPasswordParams =
            mapOf(
                "email" to updatedUser.email,
                "resetToken" to updatedUser.resetToken!!,
                "password" to newPassword,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParams)),
            ).andExpect(status().isOk)

        await.atMost(Duration.ofSeconds(5)).untilAsserted {
            val updatedSessions = sessionRepository.findByUserId(user.id)
            assertEquals(0, updatedSessions.size)
        }
    }

    @Test
    fun `cannot reset password with wrong code`() {
        val password = "Cliq123!!?"
        val user = userHelper.createRandomVerifiedUser(password = password)

        val startResetProcessParams =
            mapOf(
                "email" to user.email,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/init-reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startResetProcessParams)),
            ).andExpect(status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[0]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())

        val updatedUser = userRepository.findUserByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)

        val newPassword = "Password123!!!"
        val resetPasswordParams =
            mapOf(
                "email" to updatedUser.email,
                "resetToken" to "invalid-token",
                "password" to newPassword,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParams)),
            ).andExpect(status().isBadRequest)

        // Check that the old password is still working
        val loginParams =
            mapOf(
                "email" to user.email,
                "password" to password,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/session")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(loginParams)),
            ).andExpect(status().isCreated)
    }

    @Test
    fun `cannot reset password with expired code`() {
        val password = "Cliq123!!?"
        val user = userHelper.createRandomVerifiedUser(password = password)

        val startResetProcessParams =
            mapOf(
                "email" to user.email,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/init-reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startResetProcessParams)),
            ).andExpect(status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[0]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())

        val updatedUser = userRepository.findUserByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)

        updatedUser.resetSentAt = updatedUser.resetSentAt!!.minusMinutes(PASSWORD_RESET_TOKEN_INTERVAL_MINUTES)
        userRepository.saveAndFlush(updatedUser)

        val newPassword = "Password123!!!"
        val resetPasswordParams =
            mapOf(
                "email" to updatedUser.email,
                "resetToken" to updatedUser.resetToken!!,
                "password" to newPassword,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParams)),
            ).andExpect(status().isBadRequest)

        // Check that the old password is still working
        val loginParams =
            mapOf(
                "email" to user.email,
                "password" to password,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/session")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(loginParams)),
            ).andExpect(status().isCreated)
    }

    @Test
    fun `resend password forgot mail`() {
        val user = userHelper.createRandomVerifiedUser()

        val params = mapOf("email" to user.email)
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/init-reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))
        var updatedUser = userRepository.findUserByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)
        val oldResetToken = updatedUser.resetToken

        // Resend
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/init-reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))
        updatedUser = userRepository.findUserByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)
        val newResetToken = updatedUser.resetToken

        assertNotEquals(oldResetToken, newResetToken)

        val newPassword = "NewPassword123!!"
        // Try to reset password with old token
        val resetPasswordParamsOldToken =
            mapOf(
                "email" to updatedUser.email,
                "resetToken" to oldResetToken!!,
                "password" to newPassword,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParamsOldToken)),
            ).andExpect(status().isBadRequest)

        // reset password with new token
        val resetPasswordParamsNewToken =
            mapOf(
                "email" to updatedUser.email,
                "resetToken" to newResetToken!!,
                "password" to newPassword,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParamsNewToken)),
            ).andExpect(status().isOk)

        // Login with new password

        val loginParams =
            mapOf(
                "email" to user.email,
                "password" to newPassword,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/session")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(loginParams)),
            ).andExpect(status().isCreated)
    }

    @Test
    fun `start password reset should not leak if emails are known`() {
        val params = mapOf("email" to "unknown.email@cliq.internal")

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/init-reset-password")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(status().isNoContent)
    }
}
