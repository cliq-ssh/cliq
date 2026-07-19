package sh.cliq.backend.support

import org.awaitility.kotlin.await
import org.springframework.boot.test.context.TestComponent
import sh.cliq.backend.auth.AuthExchangeRepository
import sh.cliq.backend.auth.factory.AuthExchangeFactory
import sh.cliq.backend.auth.factory.OidcCallbackTokenFactory
import sh.cliq.backend.auth.jwt.TokenPair
import sh.cliq.backend.auth.params.RegistrationParams
import sh.cliq.backend.auth.service.JwtService
import sh.cliq.backend.constants.DEFAULT_IP_ADDRESS
import sh.cliq.backend.support.encryption.AuthenticatedEncryptionData
import sh.cliq.backend.support.encryption.EncryptionData
import sh.cliq.backend.support.encryption.EncryptionHelper
import sh.cliq.backend.support.srp.SrpData
import sh.cliq.backend.support.srp.SrpHelper
import sh.cliq.backend.user.DEFAULT_LOCALE
import sh.cliq.backend.user.User
import sh.cliq.backend.user.UserRepository
import sh.cliq.backend.user.factory.UserFactory
import sh.cliq.backend.user.service.UserService
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
    private val authExchangeFactory: AuthExchangeFactory,
    private val oidcCallbackTokenFactory: OidcCallbackTokenFactory,
    private val authExchangeRepository: AuthExchangeRepository,
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
        ipAddress: String = DEFAULT_IP_ADDRESS,
    ): AuthenticatedUserData {
        val userCreationData = createRandomUser(email, password, username, verified, locale = locale)
        val authExchange = authExchangeFactory.create(ipAddress, userCreationData.user)
        val tokenPair = jwtService.generateTokenPairFromAuthExchange(authExchange, sessionName)
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
        ipAddress: String = DEFAULT_IP_ADDRESS,
    ): TokenPair {
        val userCreationData = createRandomOidcUser(email, password, username, oidcSub, locale = locale)
        val oidcCallbackToken = oidcCallbackTokenFactory.create(ipAddress, userCreationData.user, oidcSessionId)
        val authExchange = authExchangeRepository.findById(oidcCallbackToken.authExchange.id!!).orElseThrow()

        return jwtService.generateTokenPairFromAuthExchange(authExchange, oidcSessionId)
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
        val encryptionData = encryptionHelper.createEncryptionData(password, srpData.salt.salt)
        val params =
            RegistrationParams(
                email,
                username,
                encryptionData.dataEncryptionKey.encryptedAndEncodedDataEncryptionKey,
                srpData.salt.encoded,
                srpData.verifier.encoded,
                locale,
            )
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

        return UserCreationData(
            user,
            password,
            srpData,
            encryptionData,
        )
    }
}
