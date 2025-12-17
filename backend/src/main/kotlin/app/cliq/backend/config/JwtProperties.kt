package app.cliq.backend.config

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@Configuration
@ConfigurationProperties(prefix = "app.jwt")
class JwtProperties(
    var secret: String = "secret",
    var expirationInMs: Long = 3600000L
)
