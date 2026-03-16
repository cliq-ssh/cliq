package app.cliq.backend.ratelimit

import io.github.bucket4j.Bucket
import io.github.bucket4j.BucketConfiguration
import org.springframework.cache.annotation.Cacheable
import org.springframework.stereotype.Service

@Service
class BucketService {
    // Detect things that `key` is unused when it really is not
    @Suppress("UnusedParameter")
    @Cacheable(cacheNames = [RATE_LIMIT_CACHE_NAME], key = "#key")
    fun getOrCreateBucket(
        key: String,
        config: BucketConfiguration,
    ): Bucket =
        Bucket
            .builder()
            .addLimit(config.bandwidths.first())
            .build()
}
