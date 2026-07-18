package sh.cliq.backend.config.properties

import jakarta.validation.constraints.Min
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.validation.annotation.Validated
import sh.cliq.backend.constants.MIN_JWT_EXPIRES_MINUTES
import sh.cliq.backend.constants.MIN_JWT_REFRESH_TOKEN_EXPIRES_DAYS

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
