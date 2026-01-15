package app.cliq.backend.auth.service

import app.cliq.backend.auth.factory.JwtFactory
import app.cliq.backend.auth.factory.RefreshTokenFactory
import app.cliq.backend.auth.jwt.IssuedRefreshToken
import app.cliq.backend.auth.jwt.RefreshToken
import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.session.Session
import app.cliq.backend.session.SessionFactory
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.user.User
import jakarta.transaction.Transactional
import org.springframework.stereotype.Service
import java.security.MessageDigest
import java.time.Clock
import java.time.OffsetDateTime
import java.util.HexFormat

const val TOKEN_HASH_ALGORITHM = "SHA-512"

@Service
class RefreshTokenService(
    private val refreshTokenFactory: RefreshTokenFactory,
    private val sessionFactory: SessionFactory,
    private val sessionRepository: SessionRepository,
    private val jwtFactory: JwtFactory,
    private val clock: Clock,
) {
    fun issueForOidcUser(
        user: User,
        oidcSessionId: String?,
    ): IssuedRefreshToken {
        val now = OffsetDateTime.now(clock)
        val refreshToken = refreshTokenFactory.generateJwtRefreshToken(now)
        val refreshTokenHash = hashRefreshToken(refreshToken.tokenValue)
        val session =
            sessionFactory.createFromOidcUser(
                user,
                oidcSessionId,
                RefreshToken(refreshTokenHash, refreshToken.expiresAt),
            )

        return IssuedRefreshToken(refreshToken.tokenValue, session)
    }

    fun issue(
        sessionName: String?,
        user: User,
    ): IssuedRefreshToken {
        val now = OffsetDateTime.now(clock)
        val refreshToken = refreshTokenFactory.generateJwtRefreshToken(now)
        val refreshTokenHash = hashRefreshToken(refreshToken.tokenValue)
        val session =
            sessionFactory.createWithSessionName(
                sessionName,
                user,
                RefreshToken(refreshTokenHash, refreshToken.expiresAt),
            )

        return IssuedRefreshToken(refreshToken.tokenValue, session)
    }

    @Transactional
    fun rotate(session: Session): TokenPair {
        val issuedRefreshToken = issue(session.name, session.user)
        val accessToken = jwtFactory.generateJwtAccessToken(issuedRefreshToken.session)
        val tokenPair = TokenPair.fromIssuedRefreshToken(accessToken, issuedRefreshToken)

        sessionRepository.delete(session)

        return tokenPair
    }

    fun hashRefreshToken(token: String): String {
        val md = MessageDigest.getInstance(TOKEN_HASH_ALGORITHM)
        val digest = md.digest(token.toByteArray())
        val hashedToken = HexFormat.of().formatHex(digest)

        return hashedToken
    }
}
