package app.cliq.backend.config.properties

import app.cliq.backend.constants.MIN_JWT_EXPIRES_MINUTES
import app.cliq.backend.constants.MIN_JWT_REFRESH_TOKEN_EXPIRES_DAYS
import jakarta.validation.constraints.Min
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.validation.annotation.Validated

@Validated
@ConfigurationProperties(prefix = "app.jwt")
class JwtProperties(
    var secret: String,
    @field:Min(MIN_JWT_EXPIRES_MINUTES)
    var accessTokenExpiresMinutes: Long,
    @field:Min(MIN_JWT_REFRESH_TOKEN_EXPIRES_DAYS)
    var refreshTokenExpiresDays: Long,
    var issuer: String = "self",
    var algorithm: String = "HmacSHA256",
)
