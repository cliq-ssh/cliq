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
import app.cliq.backend.utils.TokenUtils
import jakarta.transaction.Transactional
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class RefreshTokenService(
    private val refreshTokenFactory: RefreshTokenFactory,
    private val sessionFactory: SessionFactory,
    private val sessionRepository: SessionRepository,
    private val jwtFactory: JwtFactory,
    private val clock: Clock,
    private val tokenUtils: TokenUtils,
) {
    fun issueForOidcUser(
        user: User,
        oidcSessionId: String?,
    ): IssuedRefreshToken {
        val now = OffsetDateTime.now(clock)
        val refreshToken = refreshTokenFactory.generateJwtRefreshToken(now)
        val hashedRefreshToken = tokenUtils.hashTokenUsingSha512(refreshToken.tokenValue)
        val session =
            sessionFactory.createFromOidcUser(
                user,
                oidcSessionId,
                RefreshToken(hashedRefreshToken, refreshToken.expiresAt),
            )

        return IssuedRefreshToken(refreshToken.tokenValue, session)
    }

    fun issue(
        sessionName: String?,
        user: User,
    ): IssuedRefreshToken {
        val now = OffsetDateTime.now(clock)
        val refreshToken = refreshTokenFactory.generateJwtRefreshToken(now)
        val hashedRefreshToken = tokenUtils.hashTokenUsingSha512(refreshToken.tokenValue)
        val session =
            sessionFactory.createWithSessionName(
                sessionName,
                user,
                RefreshToken(hashedRefreshToken, refreshToken.expiresAt),
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
}
