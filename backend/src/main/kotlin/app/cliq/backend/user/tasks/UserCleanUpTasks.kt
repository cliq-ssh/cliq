package app.cliq.backend.user.tasks

import app.cliq.backend.user.PASSWORD_RESET_TOKEN_INTERVAL_MINUTES
import app.cliq.backend.user.UNVERIFIED_USER_INTERVAL_MINUTES
import app.cliq.backend.user.UserRepository
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.time.OffsetDateTime

@Component
class UserCleanUpTasks(
    private val userRepository: UserRepository,
    private val clock: Clock,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    /**
     * This method is scheduled to run every hour to clean up users who have not verified their email for more than
     * 1 day.
     */
    @Scheduled(cron = "0 0 * * * *")
    @Transactional
    fun cleanUpNonVerifiedUsers() {
        logger.info("Cleaning up non-verified users older than 1 day")

        val cutoffTime = OffsetDateTime.now(clock).minusMinutes(UNVERIFIED_USER_INTERVAL_MINUTES)
        val deletedCount = userRepository.deleteUnverifiedUsersOlderThan(cutoffTime)

        if (deletedCount == 0) {
            logger.info("No non-verified users found older than 1 day")
            return
        }

        logger.info("Found $deletedCount non-verified users older than 1 day")

        logger.info("Cleanup of non-verified users older than 1 day completed")
    }

    /**
     * This method is scheduled to run every 30 minutes to clean up expired password reset tokens.
     */
    @Scheduled(cron = "0 30 * * * *")
    @Transactional
    fun cleanUpExpiredPasswordResetTokens() {
        logger.info("Cleaning up expired password reset tokens")

        val cutoffTime = OffsetDateTime.now(clock).minusMinutes(PASSWORD_RESET_TOKEN_INTERVAL_MINUTES)
        val deletedCount = userRepository.deleteExpiredPasswordResetTokensOlderThan(cutoffTime)

        if (deletedCount == 0) {
            logger.info("No expired password reset tokens found")
            return
        }

        logger.info("Found $deletedCount expired password reset tokens")

        logger.info("Cleanup of expired password reset tokens completed")
    }
}
