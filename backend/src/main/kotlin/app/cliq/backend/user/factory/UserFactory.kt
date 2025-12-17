package app.cliq.backend.user.factory

import app.cliq.backend.user.DEFAULT_LOCALE
import app.cliq.backend.user.PasswordResetEvent
import app.cliq.backend.user.User
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.event.UserCreatedEvent
import app.cliq.backend.user.params.UserRegistrationParams
import org.springframework.context.ApplicationEventPublisher
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class UserFactory(
    private val passwordEncoder: PasswordEncoder,
    private val clock: Clock,
    private val eventPublisher: ApplicationEventPublisher,
    private val userRepository: UserRepository,
) {
    fun updateUserPassword(
        user: User,
        newPassword: String,
    ): User {
        val hashedPassword = passwordEncoder.encode(newPassword)

        user.resetToken = null
        user.resetSentAt = null
        user.password = hashedPassword!!
        user.updatedAt = OffsetDateTime.now(clock)

        val newUser = userRepository.save(user)
        userRepository.flush()

        val id = newUser.id ?: throw IllegalStateException("User ID should not be null after save")
        eventPublisher.publishEvent(PasswordResetEvent(id))

        return newUser
    }

    fun createFromRegistrationParams(registrationParams: UserRegistrationParams): User {
        val hashedPassword = passwordEncoder.encode(registrationParams.password)

        var user =
            createUser(
                email = registrationParams.email,
                password = hashedPassword!!,
                name = registrationParams.username,
                locale = registrationParams.locale,
            )

        user = userRepository.saveAndFlush(user)

        val id = user.id ?: throw IllegalStateException("User ID should not be null after save")
        eventPublisher.publishEvent(UserCreatedEvent(id))

        return user
    }

    private fun createUser(
        email: String,
        password: String,
        name: String,
        locale: String = DEFAULT_LOCALE,
    ): User {
        val user = User(
            email = email,
            name = name,
            locale = locale,
            createdAt = OffsetDateTime.now(clock),
            updatedAt = OffsetDateTime.now(clock),
        )
        user.password = password
        
        return user
    }
}
