package sh.cliq.backend.auth.factory

import org.springframework.stereotype.Service
import sh.cliq.backend.auth.jwt.RefreshToken
import sh.cliq.backend.config.properties.JwtProperties
import sh.cliq.backend.utils.TokenGenerator
import java.time.OffsetDateTime
import java.time.temporal.ChronoUnit

@Service
class RefreshTokenFactory(private val jwtProperties: JwtProperties, private val tokenGenerator: TokenGenerator) {
    fun generateJwtRefreshToken(now: OffsetDateTime): RefreshToken {
        val expiresAt = now.plus(jwtProperties.refreshTokenExpiresDays, ChronoUnit.DAYS)
        val token = tokenGenerator.generateJwtRefreshToken()

        return RefreshToken(token, expiresAt)
    }
}
