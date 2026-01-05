package app.cliq.backend.user.factory

import app.cliq.backend.auth.params.RegistrationParams
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

const val OIDC_PASSWORD = "OIDC USER"

@Service
class UserFactory(
    private val passwordEncoder: PasswordEncoder,
    private val clock: Clock,
    private val eventPublisher: ApplicationEventPublisher,
    private val userRepository: UserRepository,
) {
    fun createOidcUser(
        email: String,
        sub: String,
        name: String,
    ): User {
        val hashedPassword = passwordEncoder.encode(OIDC_PASSWORD)

        return createUser(
            sub = sub,
            email = email,
            password = hashedPassword!!,
            name = name,
        )
    }

    fun updateUserPassword(
        user: User,
        newPassword: String,
    ): User {
        val hashedPassword = passwordEncoder.encode(newPassword)

        user.resetToken = null
        user.resetSentAt = null
        user.password = hashedPassword!!
        user.updatedAt = OffsetDateTime.now(clock)

        val newUser = userRepository.saveAndFlush(user)

        val id = newUser.id ?: throw IllegalStateException("User ID should not be null after save")
        eventPublisher.publishEvent(PasswordResetEvent(id))

        return newUser
    }

    fun createFromRegistrationParams(registrationParams: UserRegistrationParams): User {
        val hashedPassword = passwordEncoder.encode(registrationParams.password)

        return createUser(
            email = registrationParams.email,
            password = hashedPassword!!,
            name = registrationParams.username,
            locale = registrationParams.locale,
        )
    }

    fun createFromRegistrationParams(registrationParams: RegistrationParams): User {
        val hashedPassword = passwordEncoder.encode(registrationParams.password)

        return createUser(
            email = registrationParams.email,
            password = hashedPassword!!, //Password is not null as the inputted password is not null
            name = registrationParams.username,
            locale = registrationParams.locale,
        )
    }

    private fun createUser(
        email: String,
        password: String,
        name: String,
        locale: String = DEFAULT_LOCALE,
        sub: String? = null,
    ): User {
        var user =
            User(
                oidcSub = sub,
                email = email,
                name = name,
                locale = locale,
                password = password,
                createdAt = OffsetDateTime.now(clock),
                updatedAt = OffsetDateTime.now(clock),
            )

        user = userRepository.save(user)
        val id = user.id ?: throw IllegalStateException("User ID should not be null after save")
        eventPublisher.publishEvent(UserCreatedEvent(id))

        return user
    }
}
