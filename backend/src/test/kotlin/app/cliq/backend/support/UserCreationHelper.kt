package app.cliq.backend.support

import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.auth.params.LoginParams
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.auth.service.JwtService
import app.cliq.backend.user.DEFAULT_LOCALE
import app.cliq.backend.user.User
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.factory.UserFactory
import app.cliq.backend.user.service.UserService
import org.awaitility.kotlin.await
import org.springframework.boot.test.context.TestComponent
import java.time.Duration
import kotlin.random.Random

@TestComponent
class UserCreationHelper(
    private val userService: UserService,
    private val userFactory: UserFactory,
    private val userRepository: UserRepository,
    private val jwtService: JwtService,
) {
    data class UserCreationData(
        val user: User,
        val password: String,
    )

    fun createRandomUser(
        email: String = "user${Random.nextInt(0, 9999)}@cliq.test",
        password: String = "Cliq${Random.nextInt(0, 9999)}!",
        username: String = "CliqUser${Random.nextInt(0, 9999)}!",
        verified: Boolean = true,
        locale: String = DEFAULT_LOCALE,
    ): UserCreationData {
        val user = createUser(email, password, username, verified, locale)

        return UserCreationData(user, password)
    }

    fun createRandomAuthenticatedUser(
        email: String = "user${Random.nextInt(0, 9999)}@cliq.test",
        password: String = "Cliq${Random.nextInt(0, 9999)}!",
        username: String = "CliqUser${Random.nextInt(0, 9999)}!",
        verified: Boolean = true,
        locale: String = DEFAULT_LOCALE,
    ): TokenPair {
        val userCreationData = createRandomUser(email, password, username, verified, locale)

        val loginParams =
            LoginParams(
                email,
                password,
            )

        return jwtService.generateJwtTokenPair(loginParams, userCreationData.user)
    }

    private fun createUser(
        email: String,
        password: String,
        username: String,
        verified: Boolean = true,
        locale: String = DEFAULT_LOCALE,
    ): User {
        val params = RegistrationParams(email, password, username, locale)
        var user = userFactory.createFromRegistrationParams(params)

        await.atMost(Duration.ofSeconds(5)).untilAsserted {
            val refreshedUser = userRepository.findById(user.id!!).orElseThrow()
            assert(
                refreshedUser.isEmailVerified() || refreshedUser.emailVerificationSentAt != null,
            ) {
                "Neither email verified nor verification email sent"
            }
        }

        user = userRepository.findById(user.id!!).get()

        if (verified && !user.isEmailVerified()) {
            user = userService.verifyUserEmail(user)
        }
        if (!verified && user.isEmailVerified()) {
            user.emailVerifiedAt = null
            return userRepository.saveAndFlush(user)
        }

        return user
    }
}
