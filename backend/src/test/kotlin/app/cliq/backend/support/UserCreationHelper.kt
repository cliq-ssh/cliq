package app.cliq.backend.support

import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.auth.service.JwtService
import app.cliq.backend.support.encryption.AuthenticatedEncryptionData
import app.cliq.backend.support.encryption.EncryptionData
import app.cliq.backend.support.encryption.EncryptionHelper
import app.cliq.backend.support.srp.SrpData
import app.cliq.backend.support.srp.SrpHelper
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
    private val srpHelper: SrpHelper,
    private val encryptionHelper: EncryptionHelper,
) {
    data class UserCreationData(
        val user: User,
        val password: String,
        val srpData: SrpData,
        val encryptionData: EncryptionData,
    )

    data class AuthenticatedUserData(
        val tokenPair: TokenPair,
        val userCreationData: UserCreationData,
        val authenticatedEncryptionData: AuthenticatedEncryptionData,
    )

    fun createRandomUser(
        email: String = "user${Random.nextInt(0, 9999)}@cliq.test",
        password: String = "Cliq${Random.nextInt(0, 9999)}!",
        username: String = "CliqUser${Random.nextInt(0, 9999)}!",
        verified: Boolean = true,
        locale: String = DEFAULT_LOCALE,
    ): UserCreationData = createUser(email, password, username, verified, locale = locale)

    fun createRandomOidcUser(
        email: String = "user${Random.nextInt(0, 9999)}@cliq.test",
        password: String = "Cliq${Random.nextInt(0, 9999)}!",
        username: String = "CliqUser${Random.nextInt(0, 9999)}!",
        oidcSub: String = "oidc${Random.nextInt(0, 9999)}",
        locale: String = DEFAULT_LOCALE,
    ): UserCreationData = createUser(email, password, username, locale = locale, oidcSub = oidcSub)

    fun createRandomAuthenticatedUser(
        email: String = "user${Random.nextInt(0, 9999)}@cliq.test",
        password: String = "Cliq${Random.nextInt(0, 9999)}!",
        username: String = "CliqUser${Random.nextInt(0, 9999)}!",
        verified: Boolean = true,
        locale: String = DEFAULT_LOCALE,
        sessionName: String? = null,
    ): AuthenticatedUserData {
        val userCreationData = createRandomUser(email, password, username, verified, locale = locale)
        val tokenPair = jwtService.generateJwtTokenPair(sessionName, userCreationData.user)
        val authenticatedEncryptionData =
            encryptionHelper.createAuthenticatedEncryptionData(
                userCreationData.encryptionData,
            )

        return AuthenticatedUserData(
            tokenPair,
            userCreationData,
            authenticatedEncryptionData,
        )
    }

    fun createRandomOidcAuthenticatedUser(
        email: String = "user${Random.nextInt(0, 9999)}@cliq.test",
        password: String = "Cliq${Random.nextInt(0, 9999)}!",
        username: String = "CliqUser${Random.nextInt(0, 9999)}!",
        oidcSub: String = "oidc${Random.nextInt(0, 9999)}",
        oidcSessionId: String = "oidc-session-id-${Random.nextInt(0, 9999)}",
        locale: String = DEFAULT_LOCALE,
    ): TokenPair {
        val userCreationData = createRandomOidcUser(email, password, username, oidcSub, locale = locale)

        return jwtService.generateOidcJwtTokenPair(userCreationData.user, oidcSessionId)
    }

    private fun createUser(
        email: String,
        password: String,
        username: String,
        verified: Boolean = true,
        oidcSub: String? = null,
        locale: String = DEFAULT_LOCALE,
    ): UserCreationData {
        val srpData = srpHelper.createSrpData(email, password)
        val params =
            RegistrationParams(email, password, username, srpData.salt.encoded, srpData.verifier.encoded, locale)
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

        if (oidcSub != null) {
            user.oidcSub = oidcSub
            userRepository.saveAndFlush(user)
        }

        if (verified && !user.isEmailVerified()) {
            user = userService.verifyUserEmail(user)
        }
        if (!verified && user.isEmailVerified()) {
            user.emailVerifiedAt = null
            user = userRepository.saveAndFlush(user)
        }

        val encryptionData = encryptionHelper.createEncryptionData(password, srpData.salt.salt)

        return UserCreationData(
            user,
            password,
            srpData,
            encryptionData,
        )
    }
}
