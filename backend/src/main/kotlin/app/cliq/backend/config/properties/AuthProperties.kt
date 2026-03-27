package app.cliq.backend.config.properties

import jakarta.validation.constraints.Min
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.validation.annotation.Validated

const val AUTH_EXCHANGE_DURATION_SECONDS_MIN = 10L

@Validated
@ConfigurationProperties(prefix = "app.auth")
class AuthProperties(
    val local: LocalAuthProperties,
    @Min(AUTH_EXCHANGE_DURATION_SECONDS_MIN)
    val authExchangeDurationSeconds: Long,
) {
    data class LocalAuthProperties(val registration: Boolean, val login: Boolean)
}
