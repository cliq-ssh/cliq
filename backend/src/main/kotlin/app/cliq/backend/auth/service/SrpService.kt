package app.cliq.backend.auth.service

import app.cliq.backend.auth.params.login.LoginFinishParams
import app.cliq.backend.auth.params.login.LoginStartParams
import app.cliq.backend.auth.view.login.LoginStartResponse
import app.cliq.backend.exception.InvalidCredentialsException
import app.cliq.backend.user.User
import app.cliq.backend.utils.TokenGenerator
import com.nimbusds.srp6.BigIntegerUtils
import com.nimbusds.srp6.SRP6CryptoParams
import com.nimbusds.srp6.SRP6Exception
import com.nimbusds.srp6.SRP6Routines
import com.nimbusds.srp6.SRP6VerifierGenerator
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service
import java.math.BigInteger

const val N_BIT_SIZE = 2048
const val HASH_ALGORITHM = "SHA-512"
const val AUTHENTICATION_SESSION_CACHE_NAME = "authentication-sessions"

@Service
class SrpService(
    // nimbussrp specific
    private val routines: SRP6Routines = SRP6Routines(),
    val params: SRP6CryptoParams = SRP6CryptoParams.getInstance(N_BIT_SIZE, HASH_ALGORITHM),
    val verifierGen: SRP6VerifierGenerator = SRP6VerifierGenerator(params, routines),
    // Misc
    private val tokenGenerator: TokenGenerator,
    private val srpSessionService: SrpSessionService,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    fun startAuthenticationProcess(
        user: User,
        loginStartParams: LoginStartParams,
    ): LoginStartResponse {
        val authenticationToken = tokenGenerator.generateAuthenticationToken()
        val session = srpSessionService.getOrCreateAuthenticationSession(authenticationToken, params)

        val verifier = BigIntegerUtils.fromHex(user.srpVerifier)
        val salt = BigIntegerUtils.fromHex(user.srpSalt)
        if (salt == null || verifier == null) {
            logger.error("Salt: \"${salt}\"or verifier \"${verifier}\" is null for user ${user.id}")

            throw IllegalStateException("Salt or verifier is null for user ${user.id}")
        }

        val publicB = session.step1(loginStartParams.email, salt, verifier)

        val publicBString = BigIntegerUtils.toHex(publicB)

        return LoginStartResponse(publicBString, user.srpSalt!!, authenticationToken)
    }

    fun finishAuthenticationProcess(loginFinishParams: LoginFinishParams): Pair<String, String> {
        val session =
            srpSessionService.getOrCreateAuthenticationSession(loginFinishParams.authenticationSessionToken, params)
        val publicABgInteger = BigIntegerUtils.fromHex(loginFinishParams.publicA)
        val publicM1BgInteger = BigIntegerUtils.fromHex(loginFinishParams.publicM1)
        val publicM2: BigInteger
        try {
            publicM2 = session.step2(publicABgInteger, publicM1BgInteger)
        } catch (exception: SRP6Exception) {
            logger.debug(
                "SRP authentication step 2 failed",
                exception,
            )
            throw InvalidCredentialsException()
        } finally {
            srpSessionService.evictAuthenticationSession(loginFinishParams.authenticationSessionToken)
        }
        val publicM2String = BigIntegerUtils.toHex(publicM2)

        return Pair(session.userID, publicM2String)
    }
}
