package app.cliq.backend.user.service

import app.cliq.backend.shared.EmailService
import app.cliq.backend.shared.TokenGenerator
import app.cliq.backend.user.User
import app.cliq.backend.user.UserRepository
import org.slf4j.LoggerFactory
import org.springframework.context.MessageSource
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime
import java.util.Locale

@Service
class UserService(
    private val userRepository: UserRepository,
    private val clock: Clock,
    private val tokenGenerator: TokenGenerator,
    private val emailService: EmailService,
    private val messageSource: MessageSource,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    fun verifyUserEmail(user: User): User {
        user.emailVerifiedAt = OffsetDateTime.now(clock)
        user.emailVerificationToken = null

        val updatedUser = userRepository.save(user)
        userRepository.flush()

        return updatedUser
    }

    fun sendVerificationEmail(user: User) {
        if (user.isEmailVerified()) {
            throw IllegalStateException("User email is already verified")
        }

        val token = tokenGenerator.generateEmailVerificationToken()
        user.emailVerificationToken = token
        user.emailVerificationSentAt = OffsetDateTime.now(clock)
        userRepository.save(user)

        val locale = Locale.forLanguageTag(user.locale)

        val context =
            mapOf(
                "name" to user.name,
                "verificationToken" to token,
            )

        try {
            emailService.sendEmail(
                user.email,
                messageSource.getMessage("email.verification.subject", null, locale),
                context,
                locale,
                "emailVerificationMail",
            )
        } catch (e: Throwable) {
            user.emailVerificationSentAt = null
            userRepository.save(user)

            logger.error("Failed to send verification email to user ${user.id} (${user.email})", e)

            throw e
        }
    }

    fun sendResetPasswordEmail(user: User) {
        val token = tokenGenerator.generatePasswordResetToken()
        user.resetToken = token
        user.resetSentAt = OffsetDateTime.now(clock)

        userRepository.save(user)

        val locale = Locale.forLanguageTag(user.locale)
        val context =
            mapOf<String, Any>(
                "name" to user.name,
                "resetToken" to token,
            )

        try {
            emailService.sendEmail(
                user.email,
                messageSource.getMessage("email.password_reset.subject", null, locale),
                context,
                locale,
                "passwordResetMail",
            )
        } catch (e: Throwable) {
            user.resetSentAt = null
            userRepository.save(user)

            logger.error("Failed to send password reset email to user ${user.id} (${user.email})", e)

            throw e
        }
    }
}
