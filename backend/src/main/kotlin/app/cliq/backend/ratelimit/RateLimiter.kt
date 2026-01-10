package app.cliq.backend.ratelimit

import io.github.bucket4j.Bucket
import io.github.bucket4j.BucketConfiguration
import io.github.bucket4j.ConsumptionProbe
import org.springframework.cache.Cache
import org.springframework.cache.CacheManager
import org.springframework.stereotype.Service

const val RATE_LIMIT_CACHE_NAME = "rate-limit-buckets"

@Service
class RateLimiter(
    cacheManager: CacheManager,
) {
    private val cache: Cache =
        requireNotNull(cacheManager.getCache(RATE_LIMIT_CACHE_NAME)) {
            "Missing Spring cache `$RATE_LIMIT_CACHE_NAME`"
        }

    private fun bucket(
        key: String,
        config: BucketConfiguration,
    ): Bucket {
        val wrapper = cache.get(key)
        val existing = wrapper?.get() as? Bucket
        if (existing != null) return existing

        val created = Bucket.builder().addLimit(config.bandwidths.first()).build()
        cache.put(key, created)
        return created
    }

    fun tryConsume(
        key: String,
        config: BucketConfiguration,
        tokens: Long = 1,
    ): ConsumptionProbe = bucket(key, config).tryConsumeAndReturnRemaining(tokens)
}
