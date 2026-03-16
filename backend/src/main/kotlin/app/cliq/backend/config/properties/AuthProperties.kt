package app.cliq.backend.config.properties

import jakarta.validation.constraints.Min
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.validation.annotation.Validated

const val AUTH_EXCHANGE_DURATION_MIN_SECONDS: Long = 10

@Validated
@ConfigurationProperties(prefix = "app.auth")
class AuthProperties(val local: LocalAuthProperties, val oidc: OidcAuthProperties) {
    data class LocalAuthProperties(val registration: Boolean, val login: Boolean)

    data class OidcAuthProperties(
        @Min(AUTH_EXCHANGE_DURATION_MIN_SECONDS)
        val authExchangeDurationSeconds: Long,
    )
}
