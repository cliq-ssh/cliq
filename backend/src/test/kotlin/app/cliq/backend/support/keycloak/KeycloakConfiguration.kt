package app.cliq.backend.support.keycloak

import org.keycloak.admin.client.Keycloak
import org.keycloak.admin.client.KeycloakBuilder
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.TestConfiguration
import org.springframework.context.annotation.Bean

@TestConfiguration
class KeycloakConfiguration(
    private val keycloakProperties: KeycloakProperties,
) {
    @Bean
    fun keycloak(): Keycloak =
        KeycloakBuilder
            .builder()
            .serverUrl(keycloakProperties.url)
            .realm(keycloakProperties.adminRealm)
            .clientId(keycloakProperties.clientId)
            .username(keycloakProperties.username)
            .password(keycloakProperties.password)
            .build()
}
