package app.cliq.backend.user.listener

import app.cliq.backend.shared.EmailService
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.event.UserCreatedEvent
import app.cliq.backend.user.service.UserService
import org.slf4j.LoggerFactory
import org.springframework.context.event.EventListener
import org.springframework.stereotype.Component

@Component
class UserCreatedEventListener(
    private val userRepository: UserRepository,
    private val emailService: EmailService,
    private val userService: UserService,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    @EventListener
    fun sendVerificationEmail(event: UserCreatedEvent) {
        val user =
            userRepository.findById(event.userId).orElseThrow {
                logger.warn("User with ID ${event.userId} not found")

                IllegalArgumentException("User not found")
            }

        if (!emailService.isEnabled()) {
            userService.verifyUserEmail(user)
        } else {
            userService.sendVerificationEmail(user)
        }
    }
}
