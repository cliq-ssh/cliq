package app.cliq.backend.auth.service

import app.cliq.backend.auth.factory.JwtFactory
import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.auth.params.LoginParams
import app.cliq.backend.session.Session
import app.cliq.backend.user.User
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class JwtService(
    private val jwtFactory: JwtFactory,
    private val refreshTokenService: RefreshTokenService,
    private val clock: Clock,
) {
    fun generateJwtTokenPair(
        loginParams: LoginParams,
        user: User,
    ): TokenPair {
        val now = OffsetDateTime.now(clock)
        val issuedRefreshToken = refreshTokenService.issue(loginParams.name, user)

        val jwt = jwtFactory.generateJwtAccessToken(issuedRefreshToken.session, now)

        return TokenPair(jwt, issuedRefreshToken.tokenValue, issuedRefreshToken.session)
    }

    fun generateNewAccessToken(session: Session): Jwt =
        jwtFactory.generateJwtAccessToken(session, OffsetDateTime.now(clock))
}
