package app.cliq.backend.user.service

import app.cliq.backend.email.EmailSender
import app.cliq.backend.exception.ExpiredKeyRotationCodeException
import app.cliq.backend.exception.InvalidKeyRotationCodeException
import app.cliq.backend.exception.InvalidKeyRotationParamsException
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.user.KEY_ROTATION_TOKEN_INTERVAL_MINUTES
import app.cliq.backend.user.User
import app.cliq.backend.user.UserRepository
import app.cliq.backend.utils.TokenGenerator
import app.cliq.backend.vault.VaultRepository
import app.cliq.backend.vault.factory.VaultFactory
import app.cliq.backend.vault.params.VaultParams
import org.slf4j.LoggerFactory
import org.springframework.context.MessageSource
import org.springframework.mail.MailException
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.time.OffsetDateTime
import java.util.Locale

@Service
class KeyRotationService(
    private val userRepository: UserRepository,
    private val clock: Clock,
    private val tokenGenerator: TokenGenerator,
    private val emailSender: EmailSender,
    private val messageSource: MessageSource,
    private val sessionRepository: SessionRepository,
    private val vaultRepository: VaultRepository,
    private val vaultFactory: VaultFactory,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    /**
     * Sends a key rotation code to the user's email
     * @param user The user requesting key rotation
     */
    fun sendKeyRotationEmail(user: User) {
        val code = tokenGenerator.generateKeyRotationToken()
        user.keyRotationToken = code
        user.keyRotationSentAt = OffsetDateTime.now(clock)

        userRepository.save(user)

        val locale = Locale.forLanguageTag(user.locale)
        val context =
            mapOf<String, Any>(
                "name" to user.name,
                "rotationCode" to code,
            )

        try {
            emailSender.sendEmail(
                user.email,
                messageSource.getMessage("email.key_rotation.subject", null, locale),
                context,
                locale,
                "keyRotationMail",
            )
        } catch (e: MailException) {
            user.keyRotationSentAt = null
            userRepository.save(user)

            logger.error("Failed to send key rotation email to user ${user.id} (${user.email})", e)

            throw e
        }
    }

    /**
     * Verifies the key rotation code and updates user keys
     * @param user The user rotating keys
     * @param code The verification code from email
     * @param newDataEncryptionKey The new data encryption key
     * @param srpSalt New SRP salt (required for non-OIDC users)
     * @param srpVerifier New SRP verifier (required for non-OIDC users)
     */
    @Transactional
    fun verifyKeyRotationCode(
        user: User,
        code: String,
        newDataEncryptionKey: String,
        srpSalt: String?,
        srpVerifier: String?,
        vaultParams: VaultParams,
    ) {
        if (user.keyRotationToken != code) {
            throw InvalidKeyRotationCodeException()
        }

        // Check expiration
        if (user.keyRotationSentAt == null || !isCodeValid(user.keyRotationSentAt!!)) {
            throw ExpiredKeyRotationCodeException()
        }

        // For non-OIDC users, both SRP fields are required
        if (!user.isOidcUser() && (srpSalt == null || srpVerifier == null)) {
            throw InvalidKeyRotationParamsException("SRP salt and verifier are required for non-OIDC users")
        }

        // Update keys
        user.dataEncryptionKey = newDataEncryptionKey

        // Only update SRP for non-OIDC users
        if (!user.isOidcUser()) {
            user.srpSalt = srpSalt
            user.srpVerifier = srpVerifier
        }

        // Clear the verification code and sent at
        user.keyRotationToken = null
        user.keyRotationSentAt = null

        userRepository.save(user)

        val existingVault = vaultRepository.getByUser(user)
        val vault =
            if (existingVault == null) {
                vaultFactory.createFromParams(vaultParams, user)
            } else {
                vaultFactory.updateFromParams(existingVault, vaultParams, user)
            }
        vaultRepository.save(vault)

        // Invalidate all existing sessions for this user
        sessionRepository.deleteAllByUserId(user.id!!)
        logger.info("Invalidated all sessions for user ${user.id} due to key rotation")
    }

    /**
     * Checks if a code is still valid (within the expiration window)
     * @param sentAt When the code was sent
     * @return true if the code is still valid
     */
    private fun isCodeValid(sentAt: OffsetDateTime): Boolean {
        val now = OffsetDateTime.now(clock)
        val expirationTime = sentAt.plusMinutes(KEY_ROTATION_TOKEN_INTERVAL_MINUTES)

        return now.isBefore(expirationTime)
    }
}
