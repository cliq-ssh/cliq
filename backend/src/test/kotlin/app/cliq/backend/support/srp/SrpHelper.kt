package app.cliq.backend.support.srp

import app.cliq.backend.auth.service.SrpService
import app.cliq.backend.support.encryption.KeyAndHashHelper
import com.nimbusds.srp6.BigIntegerUtils
import org.springframework.boot.test.context.TestComponent
import java.math.BigInteger
import java.security.SecureRandom

const val SALT_LENGTH = 16
const val UMK_LENGTH = 32

@TestComponent
class SrpHelper(
    private val srpService: SrpService,
    private val keyAndHashHelper: KeyAndHashHelper,
    private val secureRandom: SecureRandom = SecureRandom.getInstanceStrong()
) {
    fun createSrpData(
        email: String,
        password: String,
        salt: ByteArray = generateRandomSalt(),
    ): SrpData {
        val salt = createSrpSalt(salt)
        val verifier = createSrpVerifier(salt.asBigInteger, email, password)

        return SrpData(salt, verifier)
    }

    fun generateRandomSalt(): ByteArray {
        val salt = ByteArray(SALT_LENGTH)
        secureRandom.nextBytes(salt)

        return salt
    }

    fun generateRandomUMK(password: ByteArray, salt: ByteArray): ByteArray {
        val umk = ByteArray(UMK_LENGTH)
        val argon2Generator = keyAndHashHelper.buildArgon2BytesGenerator(salt)
        argon2Generator.generateBytes(password, umk)

        return umk
    }

    private fun createSrpSalt(salt: ByteArray): Salt {
        val srpSaltBigInteger = BigIntegerUtils.bigIntegerFromBytes(salt)
        val srpSaltString = BigIntegerUtils.toHex(srpSaltBigInteger)

        return Salt(salt, srpSaltBigInteger, srpSaltString)
    }

    private fun createSrpVerifier(salt: BigInteger, email: String, password: String): Verifier {
        val srpVerifier =
            srpService.verifierGen.generateVerifier(salt, email, password)
        val srpVerifierString = BigIntegerUtils.toHex(srpVerifier)

        return Verifier(srpVerifier, srpVerifierString)
    }
}
