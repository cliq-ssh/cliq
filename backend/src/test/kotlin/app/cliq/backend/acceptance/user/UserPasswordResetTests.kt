package app.cliq.backend.acceptance.user

import app.cliq.backend.acceptance.EmailAcceptanceTest
import app.cliq.backend.acceptance.EmailAcceptanceTester
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.support.UserCreationHelper
import app.cliq.backend.user.PASSWORD_RESET_TOKEN_INTERVAL_MINUTES
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.params.ResetPasswordParams
import app.cliq.backend.user.params.StartResetPasswordProcessParams
import org.apache.commons.mail2.jakarta.util.MimeMessageParser
import org.awaitility.kotlin.await
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNotNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers
import tools.jackson.databind.ObjectMapper
import java.time.Duration
import kotlin.test.assertEquals
import kotlin.test.assertNotEquals
import kotlin.test.assertTrue

@EmailAcceptanceTest
class UserPasswordResetTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val objectMapper: ObjectMapper,
    @Autowired private val userRepository: UserRepository,
    @Autowired private val sessionRepository: SessionRepository,
    @Autowired private val userCreationHelper: UserCreationHelper,
) : EmailAcceptanceTester() {
    @Test
    fun `reset password`() {
        val creationData = userCreationHelper.createRandomUser()
        val user = creationData.user

        val startResetProcessParams = StartResetPasswordProcessParams(user.email)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startResetProcessParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[0]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())

        var updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)

        val newPassword = "Password123!!!"
        val resetPasswordParams = ResetPasswordParams(user.email, updatedUser.resetToken!!, newPassword)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/reset")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        updatedUser = userRepository.findByEmail(user.email)

        assertNotNull(updatedUser)
        assertEquals(updatedUser.resetToken, null)
        assertEquals(updatedUser.resetSentAt, null)

        TODO("Implement SRP logic")
        val loginParams = mapOf<String, String>()

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(loginParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)
    }

    @Test
    fun `reset password deletes all sessions`() {
        val tokenPair = userCreationHelper.createRandomAuthenticatedUser()
        val session = tokenPair.session
        val user = session.user

        val sessions = sessionRepository.findByUserId(user.id!!)
        assertEquals(1, sessions.size)

        val startResetProcessParams = StartResetPasswordProcessParams(user.email)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startResetProcessParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[0]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())

        val updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)

        val newPassword = "Password123!!!"
        val resetPasswordParams = ResetPasswordParams(updatedUser.email, updatedUser.resetToken!!, newPassword)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/reset")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        await.atMost(Duration.ofSeconds(5)).untilAsserted {
            val updatedSessions = sessionRepository.findByUserId(user.id!!)
            assertEquals(0, updatedSessions.size)
        }
    }

    @Test
    fun `cannot reset password with wrong code`() {
        val password = "Cliq123!!?"
        val creationData = userCreationHelper.createRandomUser(password = password)
        val user = creationData.user

        val startResetProcessParams = StartResetPasswordProcessParams(user.email)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startResetProcessParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[0]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())

        val updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)

        val newPassword = "Password123!!!"
        val resetPasswordParams = ResetPasswordParams(updatedUser.email, "invalid-token", newPassword)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/reset")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParams)),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)

        // Check that the old password is still working
        TODO("Implement SRP logic")
        val loginParams = mapOf<String, String>()

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(loginParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)
    }

    @Test
    fun `cannot reset password with expired code`() {
        val password = "Cliq123!!?"
        val creationData = userCreationHelper.createRandomUser(password = password)
        val user = creationData.user

        val startResetProcessParams = StartResetPasswordProcessParams(user.email)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(startResetProcessParams)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))

        val emailMessages = greenMail.receivedMessages[0]
        val parser = MimeMessageParser(emailMessages).parse()
        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())

        val updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)

        updatedUser.resetSentAt = updatedUser.resetSentAt!!.minusMinutes(PASSWORD_RESET_TOKEN_INTERVAL_MINUTES)
        userRepository.saveAndFlush(updatedUser)

        val newPassword = "Password123!!!"
        val resetPasswordParams = ResetPasswordParams(updatedUser.email, updatedUser.resetToken!!, newPassword)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/reset")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParams)),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)

        // Check that the old password is still working
        TODO("Implement SRP logic")
        val loginParams = mapOf<String, String>()

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(loginParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)
    }

    @Test
    fun `resend password forgot mail`() {
        val creationData = userCreationHelper.createRandomUser()
        val user = creationData.user

        val params = StartResetPasswordProcessParams(user.email)
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))
        var updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)
        val oldResetToken = updatedUser.resetToken

        // Resend
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)

        assertTrue(greenMail.waitForIncomingEmail(1))
        updatedUser = userRepository.findByEmail(user.email)
        assertNotNull(updatedUser)
        assertNotNull(updatedUser.resetToken)
        val newResetToken = updatedUser.resetToken

        assertNotEquals(oldResetToken, newResetToken)

        val newPassword = "NewPassword123!!"
        // Try to reset password with old token
        val resetPasswordParamsOldToken = ResetPasswordParams(updatedUser.email, oldResetToken!!, newPassword)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/reset")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParamsOldToken)),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)

        // reset password with new token
        val resetPasswordParamsNewToken = ResetPasswordParams(updatedUser.email, updatedUser.resetToken!!, newPassword)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/reset")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(resetPasswordParamsNewToken)),
            ).andExpect(MockMvcResultMatchers.status().isOk)

        // Login with new password

        TODO("Implement SRP logic")
        val loginParams = mapOf<String, String>()

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/login")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(loginParams)),
            ).andExpect(MockMvcResultMatchers.status().isOk)
    }

    @Test
    fun `start password reset should not leak if emails are known`() {
        val email = "unknown.email@cliq.internal"
        val params = StartResetPasswordProcessParams(email)

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/user/password-reset/start")
                    .contentType(MediaType.APPLICATION_JSON)
                    .content(objectMapper.writeValueAsString(params)),
            ).andExpect(MockMvcResultMatchers.status().isNoContent)
    }
}
