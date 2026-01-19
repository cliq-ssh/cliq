package app.cliq.backend.session.tasks

import app.cliq.backend.session.SessionRepository
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.time.OffsetDateTime

@Component
class DeleteExpiredSessionTask(
    private val sessionRepository: SessionRepository,
    private val clock: Clock,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    /**
     * This method is scheduled to run every hour to clean up expired sessions.
     */
    @Scheduled(cron = "0 0 * * * *")
    @Transactional
    fun deleteExpiredSessions() {
        val now = OffsetDateTime.now(clock)
        val deleteCount = sessionRepository.deleteAllByExpiresAtBefore(now)

        logger.info("Deleted $deleteCount expired sessions")
    }
}
