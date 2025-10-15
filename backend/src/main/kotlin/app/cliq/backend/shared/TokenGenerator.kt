package app.cliq.backend.shared

import org.springframework.stereotype.Service
import java.security.SecureRandom
import java.util.Base64
import java.util.Locale.getDefault
import java.util.UUID

const val RANDOM_BYTES_LENGTH = 32
const val EMAIL_VERIFICATION_TOKEN_LENGTH: UShort = 8U
const val RESET_PASSWORD_TOKEN_LENGTH: UShort = 8U
const val AUTH_VERIFICATION_TOKEN_LENGTH: UShort = 64U

@Service
class TokenGenerator {
    private val secureRandom = SecureRandom()
    private val base64Encoder = Base64.getUrlEncoder().withoutPadding()

    fun generateToken(length: UShort = 64U): String {
        val randomBytes = ByteArray(RANDOM_BYTES_LENGTH)
        secureRandom.nextBytes(randomBytes)

        val uuid = UUID.randomUUID()

        val combined = uuid.toString().toByteArray() + randomBytes

        val fullToken = base64Encoder.encodeToString(combined)
        return fullToken.take(length.toInt())
    }

    fun generateEmailVerificationToken(): String =
        generateToken(EMAIL_VERIFICATION_TOKEN_LENGTH).uppercase(getDefault())

    fun generatePasswordResetToken(): String = generateToken(RESET_PASSWORD_TOKEN_LENGTH).uppercase(getDefault())

    fun generateAuthVerificationToken(): String = generateToken(AUTH_VERIFICATION_TOKEN_LENGTH)
}
