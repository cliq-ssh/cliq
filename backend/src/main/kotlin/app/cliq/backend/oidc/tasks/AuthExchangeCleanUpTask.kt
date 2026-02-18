package app.cliq.backend.oidc.tasks

import app.cliq.backend.oidc.AuthExchangeRepository
import app.cliq.backend.session.SessionRepository
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.time.Clock
import java.time.OffsetDateTime

@Component
class AuthExchangeCleanUpTask(
    private val authExchangeRepository: AuthExchangeRepository,
    private val sessionRepository: SessionRepository,
    private val clock: Clock,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    /**
     * This method is scheduled to run five minutes to clean up expired auth exchanges.
     */
    @Scheduled(cron = "0 */5 * * * *")
    @Transactional
    fun cleanUpExpiredAuthExchanges() {
        val expiredAuthExchanges = authExchangeRepository.getExpiredAuthExchanges(OffsetDateTime.now(clock))
        for (authExchange in expiredAuthExchanges) {
            authExchangeRepository.delete(authExchange)
            sessionRepository.delete(authExchange.session)
        }

        logger.info("Found ${expiredAuthExchanges.size} expired auth exchanges")
    }
}
