package app.cliq.backend.config.oidc

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app.oidc")
class OidcProperties(
    var enabled: Boolean = false,
    var issuerUri: String? = null,
    var clientId: String? = null,
)
