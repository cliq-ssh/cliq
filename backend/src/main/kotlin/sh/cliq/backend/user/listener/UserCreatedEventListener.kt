package sh.cliq.backend.user.listener

import org.slf4j.LoggerFactory
import org.springframework.context.event.EventListener
import org.springframework.stereotype.Component
import sh.cliq.backend.email.EmailSender
import sh.cliq.backend.user.UserRepository
import sh.cliq.backend.user.event.UserCreatedEvent
import sh.cliq.backend.user.service.UserService

@Component
class UserCreatedEventListener(
    private val userRepository: UserRepository,
    private val userService: UserService,
    private val emailSender: EmailSender,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    @EventListener
    fun sendVerificationEmail(event: UserCreatedEvent) {
        val user =
            userRepository.findById(event.userId).orElseThrow {
                logger.warn("User with ID ${event.userId} not found")

                IllegalArgumentException("User not found")
            }

        if (!emailSender.isEnabled()) {
            userService.verifyUserEmail(user)
        } else {
            userService.sendVerificationEmail(user)
        }
    }
}
