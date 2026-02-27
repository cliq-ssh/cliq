package app.cliq.backend.user.factory

import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.user.DEFAULT_LOCALE
import app.cliq.backend.user.User
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.event.UserCreatedEvent
import org.springframework.context.ApplicationEventPublisher
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class UserFactory(
    private val clock: Clock,
    private val eventPublisher: ApplicationEventPublisher,
    private val userRepository: UserRepository,
) {
    fun createOidcUser(
        email: String,
        sub: String,
        name: String,
    ): User =
        createUser(
            sub = sub,
            email = email,
            name = name,
            srpSalt = null,
            srpVerifier = null,
        )

    fun createFromRegistrationParams(registrationParams: RegistrationParams): User =
        createUser(
            email = registrationParams.email,
            name = registrationParams.username,
            locale = registrationParams.locale,
            dataEncryptionKey = registrationParams.dataEncryptionKey,
            srpSalt = registrationParams.srpSalt,
            srpVerifier = registrationParams.srpVerifier,
        )

    private fun createUser(
        email: String,
        name: String,
        srpSalt: String?,
        srpVerifier: String?,
        locale: String = DEFAULT_LOCALE,
        sub: String? = null,
        dataEncryptionKey: String? = null,
    ): User {
        var user =
            User(
                oidcSub = sub,
                email = email,
                name = name,
                locale = locale,
                dataEncryptionKey = dataEncryptionKey,
                createdAt = OffsetDateTime.now(clock),
                updatedAt = OffsetDateTime.now(clock),
                srpSalt = srpSalt,
                srpVerifier = srpVerifier,
            )

        user = userRepository.save(user)
        val id = user.id ?: throw IllegalStateException("User ID should not be null after save")
        eventPublisher.publishEvent(UserCreatedEvent(id))

        return user
    }
}
