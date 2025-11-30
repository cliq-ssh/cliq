package app.cliq.backend.user

import app.cliq.backend.AcceptanceTest
import app.cliq.backend.AcceptanceTester
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.support.UserHelper
import org.apache.commons.mail2.jakarta.util.MimeMessageParser
import org.awaitility.kotlin.await
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNotNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper
import java.time.Duration
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue

@AcceptanceTest
class UserPasswordResetAcceptanceTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val objectMapper: ObjectMapper,
    @Autowired private val userRepository: UserRepository,
    @Autowired private val sessionRepository: SessionRepository,
    @Autowired private val userHelper: UserHelper,
) : AcceptanceTester() {
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
                    .post("/api/v1/user/password-reset/start")
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
                    .post("/api/v1/user/password-reset/reset")
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
        session = sessionRepository.findById(session.id!!).orElseThrow()
        val user = userRepository.findById(session.user.id!!).orElseThrow()

        val sessions = sessionRepository.findByUserId(user.id!!)
        assertEquals(1, sessions.size)

        val startResetProcessParams =
            mapOf(
                "email" to user.email,
            )

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/v1/user/password-reset/start")
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
                    .post("/api/v1/user/password-reset/reset")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParams)),
            ).andExpect(status().isOk)

        await.atMost(Duration.ofSeconds(5)).untilAsserted {
            val updatedSessions = sessionRepository.findByUserId(user.id!!)
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
                    .post("/api/v1/user/password-reset/start")
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
                    .post("/api/v1/user/password-reset/reset")
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
                    .post("/api/v1/user/password-reset/start")
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
                    .post("/api/v1/user/password-reset/reset")
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
                    .post("/api/v1/user/password-reset/start")
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
                    .post("/api/v1/user/password-reset/start")
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
                    .post("/api/v1/user/password-reset/reset")
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
                    .post("/api/v1/user/password-reset/reset")
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
                    .post("/api/v1/user/password-reset/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(status().isNoContent)
    }
}
