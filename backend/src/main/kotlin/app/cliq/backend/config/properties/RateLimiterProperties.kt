package app.cliq.backend.config.properties

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app")
data class RateLimiterProperties(
    val rateLimits: List<RateLimit> = emptyList(),
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
