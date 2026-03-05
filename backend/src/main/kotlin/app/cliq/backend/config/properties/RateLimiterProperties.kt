package app.cliq.backend.config.properties

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app.rate-limits")
data class RateLimiterProperties(
    val enabled: Boolean = true,
    val routes: List<RateLimit> = emptyList(),
) {
    data class RateLimit(
        val name: String,
        val url: String,
        val target: Target,
        val requestsPerMinute: Int,
    )

    enum class Target {
        IP,
//        USER
    }
}
