package app.cliq.backend.ratelimit

import io.github.bucket4j.BucketConfiguration
import io.github.bucket4j.ConsumptionProbe
import org.springframework.stereotype.Service

const val RATE_LIMIT_CACHE_NAME = "rate-limit-buckets"

@RateLimiterFeature
@Service
class RateLimiter(
    private val bucketService: BucketService,
) {
    fun tryConsume(
        key: String,
        config: BucketConfiguration,
        tokens: Long = 1,
    ): ConsumptionProbe = bucketService.getOrCreateBucket(key, config).tryConsumeAndReturnRemaining(tokens)
}
