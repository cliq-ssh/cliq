package app.cliq.backend.utils

import org.springframework.stereotype.Service
import java.security.MessageDigest
import java.util.HexFormat

const val TOKEN_HASH_ALGORITHM = "SHA-512"

@Service
class TokenUtils {
    fun hashTokenUsingSha512(token: String): String {
        val md = MessageDigest.getInstance(TOKEN_HASH_ALGORITHM)
        val digest = md.digest(token.toByteArray())
        val hashedToken = HexFormat.of().formatHex(digest)

        return hashedToken
    }
}
