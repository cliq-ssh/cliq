package app.cliq.backend.support.keycloak

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app.keycloak")
class KeycloakProperties(
    val url: String,
    val username: String,
    val password: String,
    val realm: String = "cliq-test",
    val adminRealm: String = "master",
    val clientId: String = "admin-cli",
)
