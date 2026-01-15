package app.cliq.backend.utils

import org.springframework.stereotype.Service
import java.security.SecureRandom
import java.util.Base64
import java.util.Locale.getDefault
import java.util.random.RandomGenerator

const val JWT_REFRESH_TOKEN_LENGTH: UShort = 128U
const val EMAIL_VERIFICATION_TOKEN_LENGTH: UShort = 8U
const val RESET_PASSWORD_TOKEN_LENGTH: UShort = 8U

@Service
class TokenGenerator(
    private val secureRandomGenerator: RandomGenerator = SecureRandom(),
    private val base64Encoder: Base64.Encoder = Base64.getUrlEncoder().withoutPadding(),
) {
    fun generateJwtRefreshToken(): String = generateToken(JWT_REFRESH_TOKEN_LENGTH)

    fun generateEmailVerificationToken(): String =
        generateToken(EMAIL_VERIFICATION_TOKEN_LENGTH).uppercase(getDefault())

    fun generatePasswordResetToken(): String = generateToken(RESET_PASSWORD_TOKEN_LENGTH).uppercase(getDefault())

    private fun generateToken(length: UShort): String {
        val randomBytes = ByteArray(length.toInt())
        secureRandomGenerator.nextBytes(randomBytes)

        return base64Encoder.encodeToString(randomBytes).take(length.toInt())
    }
}
