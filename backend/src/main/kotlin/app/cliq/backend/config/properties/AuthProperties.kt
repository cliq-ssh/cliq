package app.cliq.backend.config.properties

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app.auth")
class AuthProperties(
    val local: LocalAuthProperties,
) {
    data class LocalAuthProperties(
        val registration: Boolean,
        val login: Boolean,
    )
}
