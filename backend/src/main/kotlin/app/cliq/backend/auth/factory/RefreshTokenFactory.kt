package app.cliq.backend.auth.factory

import app.cliq.backend.auth.jwt.RefreshToken
import app.cliq.backend.config.properties.JwtProperties
import app.cliq.backend.utils.TokenGenerator
import org.springframework.stereotype.Service
import java.time.OffsetDateTime
import java.time.temporal.ChronoUnit

@Service
class RefreshTokenFactory(
    private val jwtProperties: JwtProperties,
    private val tokenGenerator: TokenGenerator,
) {
    fun generateJwtRefreshToken(now: OffsetDateTime): RefreshToken {
        val expiresAt = now.plus(jwtProperties.refreshTokenExpiresDays, ChronoUnit.DAYS)
        val token = tokenGenerator.generateJwtRefreshToken()

        return RefreshToken(token, expiresAt)
    }
}
