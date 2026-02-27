package app.cliq.backend.ratelimit

import org.springframework.boot.autoconfigure.condition.ConditionalOnBooleanProperty

@ConditionalOnBooleanProperty("app.rate-limits.enabled")
annotation class RateLimiterFeature
