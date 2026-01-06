package app.cliq.backend.auth.service

import app.cliq.backend.auth.factory.JwtFactory
import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.auth.params.LoginParams
import app.cliq.backend.session.SessionFactory
import app.cliq.backend.user.User
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class JwtService(
    private val jwtFactory: JwtFactory,
    private val sessionFactory: SessionFactory,
    private val clock: Clock,
) {
    fun generateJwtTokenPair(
        loginParams: LoginParams,
        user: User,
    ): TokenPair {
        val now = OffsetDateTime.now(clock)
        val refreshToken = jwtFactory.generateJwtRefreshToken(now)
        val session =
            sessionFactory.createFromLoginParams(
                loginParams,
                user,
                refreshToken,
            )

        val jwt = jwtFactory.generateJwtAccessToken(session, now)

        return TokenPair(jwt, refreshToken, session)
    }
}
