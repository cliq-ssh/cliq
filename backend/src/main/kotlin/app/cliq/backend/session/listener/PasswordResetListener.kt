package app.cliq.backend.session.listener

import app.cliq.backend.session.SessionRepository
import app.cliq.backend.user.PasswordResetEvent
import app.cliq.backend.user.UserRepository
import org.slf4j.LoggerFactory
import org.springframework.context.event.EventListener
import org.springframework.scheduling.annotation.Async
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional

@Component
class PasswordResetListener(
    private val userRepository: UserRepository,
    private val sessionRepository: SessionRepository,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    @Async
    @EventListener
    @Transactional
    fun deleteAllSessions(event: PasswordResetEvent) {
        val user =
            userRepository.findById(event.userId).orElseThrow {
                logger.warn("User with ID ${event.userId} not found")

                IllegalArgumentException("User not found")
            }

        sessionRepository.deleteAllByUserId(user.id!!)
    }
}
