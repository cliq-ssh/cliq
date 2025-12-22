package app.cliq.backend.config

import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.context.annotation.Configuration

@Configuration
@ConfigurationProperties(prefix = "app.oidc")
class OidcProperties(
    var enabled: Boolean = false,
    var issuerUri: String? = null,
    var clientId: String? = null,
)
