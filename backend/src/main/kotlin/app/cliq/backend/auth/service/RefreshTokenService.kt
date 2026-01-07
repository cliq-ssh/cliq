package app.cliq.backend.auth.service

import app.cliq.backend.auth.factory.JwtFactory
import app.cliq.backend.session.Session
import app.cliq.backend.session.SessionFactory
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.utils.TokenGenerator
import org.springframework.stereotype.Service
import java.security.MessageDigest
import java.time.OffsetDateTime
import java.util.HexFormat

const val TOKEN_HASH_ALGORITHM = "SHA-512"

@Service
class RefreshTokenService(
    private val jwtFactory: JwtFactory,
    private val sessionFactory: SessionFactory,
    private val tokenGenerator: TokenGenerator,
    private val sessionRepository: SessionRepository,
) {
//    fun issue(now: OffsetDateTime): String {
//        val refreshToken = jwtFactory.generateJwtRefreshToken(now)
//    }

    fun rotate(session: Session): Session {
        val newRefreshToken = tokenGenerator.generateJwtRefreshToken()
        session.refreshToken = newRefreshToken

        return sessionRepository.save(session)
    }

    private fun sha512Hex(token: String): String {
        val md = MessageDigest.getInstance(TOKEN_HASH_ALGORITHM)
        val digest = md.digest(token.toByteArray())
        val hashedToken = HexFormat.of().formatHex(digest)

        return hashedToken
    }
}
