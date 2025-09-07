package app.cliq.backend.user.listener

import app.cliq.backend.api.session.SessionRepository
import app.cliq.backend.api.user.UserRepository
import app.cliq.backend.api.user.event.PasswordResetEvent
import jakarta.transaction.Transactional
import org.slf4j.LoggerFactory
import org.springframework.context.event.EventListener
import org.springframework.stereotype.Component

@Component
class PasswordResetListener(
    private val userRepository: UserRepository,
    private val sessionRepository: SessionRepository,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    @EventListener
    @Transactional
    fun deleteAllSessions(event: PasswordResetEvent) {
        val user =
            userRepository.findById(event.userId).orElseThrow {
                logger.warn("User with ID ${event.userId} not found")

                IllegalArgumentException("User not found")
            }

        sessionRepository.deleteAllByUserId(user.id)
    }
}
