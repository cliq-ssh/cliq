package app.cliq.backend.support

import app.cliq.backend.session.Session
import app.cliq.backend.session.SessionFactory
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.session.params.SessionCreationParams
import app.cliq.backend.user.User
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.factory.UserFactory
import app.cliq.backend.user.params.UserRegistrationParams
import app.cliq.backend.user.service.UserService
import org.awaitility.kotlin.await
import org.springframework.boot.test.context.TestComponent
import java.time.Duration
import kotlin.random.Random

@TestComponent
class UserHelper(
    private val sessionRepository: SessionRepository,
    private val userRepository: UserRepository,
    private val userFactory: UserFactory,
    private val userService: UserService,
    private val sessionFactory: SessionFactory,
) {
    fun createRandomNonVerifiedUser(
        email: String = "user${Random.nextInt(0, 9999)}@cliq.test",
        password: String = "Cliq${Random.nextInt(0, 9999)}!",
        username: String = "CliqUser${Random.nextInt(0, 9999)}!",
    ): User {
        val params = UserRegistrationParams(email, password, username)
        val user = userFactory.createFromRegistrationParams(params)

        return user
    }

    fun createRandomVerifiedUser(
        email: String = "user${Random.nextInt(0, 9999)}@cliq.test",
        password: String = "Cliq${Random.nextInt(0, 9999)}!",
        username: String = "CliqUser${Random.nextInt(0, 9999)}!",
    ): User {
        var user = createRandomNonVerifiedUser(email, password, username)

        // We need to wait for the `UserCreatedEvent` event to be finished processing to prevent data
        await.atMost(Duration.ofSeconds(5)).untilAsserted {
            val refreshedUser = userRepository.findById(user.id!!).orElseThrow()
            assert(
                refreshedUser.isEmailVerified() || refreshedUser.emailVerificationSentAt != null,
            ) {
                "Neither email verified nor verification email sent"
            }
        }

        user = userRepository.findById(user.id!!).get()
        if (!user.isEmailVerified()) {
            user = userService.verifyUserEmail(user)
        }

        return user
    }

    fun createRandomAuthenticatedUser(
        email: String = "user${Random.nextInt(0, 9999)}@cliq.test",
        password: String = "Cliq${Random.nextInt(0, 9999)}!",
        username: String = "CliqUser${Random.nextInt(0, 9999)}!",
    ): Session {
        val user = createRandomVerifiedUser(email, password, username)

        val params = SessionCreationParams(email, password)
        val session = sessionFactory.createFromCreationParams(params, user)
        val updatedSession = sessionRepository.saveAndFlush(session)

        return updatedSession
    }
}
