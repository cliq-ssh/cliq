package app.cliq.backend.auth.tasks

import app.cliq.backend.auth.AuthExchangeRepository
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.time.OffsetDateTime

@Component
class AuthExchangeCleanUpTask(
    private val authExchangeRepository: AuthExchangeRepository,
    private val clock: Clock,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    /**
     * This method is scheduled to run five minutes to clean up expired auth exchanges.
     */
    @Scheduled(cron = "0 */5 * * * *")
    @Transactional
    fun cleanUpExpiredAuthExchanges() {
        val now = OffsetDateTime.now(clock)
        val deletedCount = authExchangeRepository.deleteExpiredAuthExchanges(now)
        if (deletedCount > 0) {
            logger.info("Deleted $deletedCount expired auth exchanges")
        }
    }
}
