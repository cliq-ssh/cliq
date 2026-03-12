package app.cliq.backend.config.properties

import jakarta.validation.constraints.Min
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.validation.annotation.Validated

@Validated
@ConfigurationProperties(prefix = "app.auth")
class AuthProperties(
    val local: LocalAuthProperties,
    @Min(10)
    val authExchangeDurationSeconds: Long,
) {
    data class LocalAuthProperties(
        val registration: Boolean,
        val login: Boolean,
    )
}
