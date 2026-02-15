package app.cliq.backend.support

import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.auth.service.JwtService
import app.cliq.backend.auth.service.SrpService
import app.cliq.backend.constants.DEFAULT_DATA_ENCRYPTION_KEY
import app.cliq.backend.constants.DEFAULT_EMAIL
import app.cliq.backend.constants.DEFAULT_SRP_SALT
import app.cliq.backend.constants.DEFAULT_SRP_VERIFIER
import app.cliq.backend.constants.DEFAULT_USERNAME
import app.cliq.backend.support.encryption.EncryptionData
import app.cliq.backend.support.encryption.EncryptionHelper
import app.cliq.backend.support.srp.SrpData
import app.cliq.backend.support.srp.SrpHelper
import app.cliq.backend.user.DEFAULT_LOCALE
import app.cliq.backend.user.User
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.factory.UserFactory
import app.cliq.backend.user.service.UserService
import com.nimbusds.srp6.BigIntegerUtils
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
    private val srpService: SrpService,
    private val srpHelper: SrpHelper,
    private val encryptionHelper: EncryptionHelper,
) {
    data class UserCreationData(
        val user: User,
        val password: String,
        val srpData: SrpData,
        val encryptionData: EncryptionData,
    )

    fun getDefaultRegistrationParams(): RegistrationParams {
        return RegistrationParams(
            email = DEFAULT_EMAIL,
            username = DEFAULT_USERNAME,
            dataEncryptionKey = DEFAULT_DATA_ENCRYPTION_KEY,
            srpSalt = DEFAULT_SRP_SALT,
            srpVerifier = DEFAULT_SRP_VERIFIER,
        )
    }

    fun createRandomUser(
        email: String = "user${Random.nextInt(0, 9999)}@cliq.test",
        password: String = "Cliq${Random.nextInt(0, 9999)}!",
        username: String = "CliqUser${Random.nextInt(0, 9999)}!",
        verified: Boolean = true,
        locale: String = DEFAULT_LOCALE,
    ): UserCreationData {
        return createUser(email, password, username, verified, locale)
    }

    fun createRandomAuthenticatedUser(
        email: String = "user${Random.nextInt(0, 9999)}@cliq.test",
        password: String = "Cliq${Random.nextInt(0, 9999)}!",
        username: String = "CliqUser${Random.nextInt(0, 9999)}!",
        verified: Boolean = true,
        locale: String = DEFAULT_LOCALE,
    ): TokenPair {
        val userCreationData = createRandomUser(email, password, username, verified, locale)

        return jwtService.generateJwtTokenPair(null, userCreationData.user)
    }

    private fun createUser(
        email: String,
        password: String,
        username: String,
        verified: Boolean = true,
        locale: String = DEFAULT_LOCALE,
    ): UserCreationData {
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
            user = userRepository.saveAndFlush(user)
        }

        val salt = srpHelper.generateRandomSalt()
        val umk = srpHelper.generateRandomUMK(password.toByteArray(), salt)

        val srpSaltBigInteger = BigIntegerUtils.bigIntegerFromBytes(salt)
        val srpVerifier =
            srpService.verifierGen.generateVerifier(srpSaltBigInteger, email, password)
        val srpVerifierString = BigIntegerUtils.toHex(srpVerifier)
        val srpSaltString = BigIntegerUtils.toHex(srpSaltBigInteger)

        val srpData = SrpData(
            salt = Salt(salt, srpSaltString),
            verifier = Verifier(srpVerifier, srpVerifierString),
        )

        return UserCreationData(
            user,
            Umk(umk)
        )
    }
}
