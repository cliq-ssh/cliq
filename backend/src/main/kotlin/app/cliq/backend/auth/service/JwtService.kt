package app.cliq.backend.auth.service

import app.cliq.backend.auth.factory.JwtFactory
import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.auth.params.login.LoginFinishParams
import app.cliq.backend.user.User
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
        loginFinishParams: LoginFinishParams,
        user: User,
    ): TokenPair = generateJwtTokenPair(loginFinishParams.sessionName, user)

    fun generateJwtTokenPair(
        sessionName: String?,
        user: User,
    ): TokenPair {
        val now = OffsetDateTime.now(clock)
        val issuedRefreshToken = refreshTokenService.issue(sessionName, user)

        val jwt = jwtFactory.generateJwtAccessToken(issuedRefreshToken.session, now)

        return TokenPair(jwt, issuedRefreshToken.tokenValue, issuedRefreshToken.session)
    }

    fun generateOidcJwtTokenPair(
        user: User,
        oidcSessionId: String?,
    ): TokenPair {
        val now = OffsetDateTime.now(clock)
        val issuedRefreshToken = refreshTokenService.issueForOidcUser(user, oidcSessionId)

        val jwt = jwtFactory.generateJwtAccessToken(issuedRefreshToken.session, now)

        return TokenPair(jwt, issuedRefreshToken.tokenValue, issuedRefreshToken.session)
    }
}
