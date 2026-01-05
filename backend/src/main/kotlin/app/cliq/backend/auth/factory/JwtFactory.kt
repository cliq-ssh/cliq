package app.cliq.backend.auth.factory

import app.cliq.backend.auth.jwt.RefreshToken
import app.cliq.backend.config.properties.JwtProperties
import app.cliq.backend.session.Session
import app.cliq.backend.utils.TokenGenerator
import org.springframework.security.oauth2.jwt.Jwt
import org.springframework.security.oauth2.jwt.JwtClaimsSet
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.JwtEncoderParameters
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime
import java.time.temporal.ChronoUnit

@Service
class JwtFactory(
    private val jwtProperties: JwtProperties,
    private val jwtEncoder: JwtEncoder,
    private val tokenGenerator: TokenGenerator,
) {
    fun generateJwtAccessToken(session: Session, now: OffsetDateTime): Jwt {
        val user = session.user
        if (session.id == null) throw IllegalArgumentException("Session must have an ID")
        if (user.id == null) throw IllegalArgumentException("User must have an ID")

        val accessTokenExpiresAt = now.plus(jwtProperties.accessTokenExpiresMinutes, ChronoUnit.MINUTES)

        val claims = JwtClaimsSet.builder()
            .issuer(jwtProperties.issuer)
            .issuedAt(now.toInstant())
            .expiresAt(accessTokenExpiresAt.toInstant())
            .subject(user.id.toString())
            .claim("sid", session.id)
            .build()

        return jwtEncoder.encode(JwtEncoderParameters.from(claims))
    }

    fun generateJwtRefreshToken(now: OffsetDateTime): RefreshToken {
        val expiresAt = now.plus(jwtProperties.refreshTokenExpiresDays, ChronoUnit.DAYS)
        val token = tokenGenerator.generateJwtRefreshToken()

        return RefreshToken(token, expiresAt)
    }
}
