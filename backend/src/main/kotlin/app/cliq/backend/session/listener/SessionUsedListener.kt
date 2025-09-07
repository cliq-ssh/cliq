package app.cliq.backend.session.listener

import app.cliq.backend.session.SessionRepository
import app.cliq.backend.session.event.SessionUsedEvent
import org.slf4j.LoggerFactory
import org.springframework.context.event.EventListener
import org.springframework.stereotype.Component
import java.time.Clock
import java.time.OffsetDateTime

@Component
class SessionUsedListener(
    private val sessionRepository: SessionRepository,
    private val clock: Clock,
) {
    private val logger = LoggerFactory.getLogger(SessionUsedListener::class.java)

    @EventListener(SessionUsedEvent::class)
    fun updateSessionUsage(event: SessionUsedEvent) {
        val session =
            sessionRepository.findById(event.sessionId).orElseThrow {
                logger.warn("Session with ID ${event.sessionId} not found")

                IllegalArgumentException("Session with ID ${event.sessionId} not found")
            }

        session.lastAccessedAt = OffsetDateTime.now(clock)

        sessionRepository.save(session)
    }
}
