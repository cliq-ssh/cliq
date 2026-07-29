package sh.cliq.backend.config.properties

import jakarta.validation.constraints.Min
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.validation.annotation.Validated

const val AUTH_EXCHANGE_DURATION_SECONDS_MIN = 10L

@Validated
@ConfigurationProperties(prefix = "app.auth")
data class AuthProperties(
    val providers: Providers,
    @Min(AUTH_EXCHANGE_DURATION_SECONDS_MIN)
    val authExchangeDurationSeconds: Long,
) {
    data class Providers(
        val local: LocalProvider,
        val oidc: OidcProvider
    )

    data class LocalProvider(
        val enabled: Boolean,
        val registrationEnabled: Boolean
    )

    data class OidcProvider(
        val enabled: Boolean
    )
}
