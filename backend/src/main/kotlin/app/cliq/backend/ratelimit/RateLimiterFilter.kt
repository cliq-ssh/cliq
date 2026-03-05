package app.cliq.backend.ratelimit

import app.cliq.backend.config.properties.RateLimiterProperties
import io.github.bucket4j.Bandwidth
import io.github.bucket4j.BucketConfiguration
import jakarta.servlet.FilterChain
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.security.web.servlet.util.matcher.PathPatternRequestMatcher
import org.springframework.stereotype.Component
import org.springframework.web.filter.OncePerRequestFilter
import java.time.Duration
import kotlin.time.Duration.Companion.nanoseconds

@RateLimiterFeature
@Component
class RateLimiterFilter(
    private val rateLimiterProperties: RateLimiterProperties,
    private val rateLimiter: RateLimiter,
    private val rateLimitResponseBuilder: RateLimitResponseBuilder,
) : OncePerRequestFilter() {
    override fun doFilterInternal(
        request: HttpServletRequest,
        response: HttpServletResponse,
        filterChain: FilterChain,
    ) {
        val rule = findRule(request)
        if (rule == null) {
            filterChain.doFilter(request, response)
            return
        }

        val key = buildKey(rule, request)
        val config = bucketConfig(rule.requestsPerMinute)

        val probe = rateLimiter.tryConsume(key = key, config = config, tokens = 1)

        if (probe.isConsumed) {
            filterChain.doFilter(request, response)
            return
        }

        val retryAfterSeconds = probe.nanosToWaitForRefill.nanoseconds.inWholeSeconds
        rateLimitResponseBuilder.buildResponse(response, retryAfterSeconds)
    }

    private fun findRule(request: HttpServletRequest): RateLimiterProperties.RateLimit? =
        rateLimiterProperties.routes.firstOrNull {
            matches(it.url, request)
        }

    private fun matches(
        url: String,
        request: HttpServletRequest,
    ): Boolean {
        val matcher = PathPatternRequestMatcher.pathPattern(url)

        return matcher.matches(request)
    }

    private fun buildKey(
        rule: RateLimiterProperties.RateLimit,
        request: HttpServletRequest,
    ): String {
        val subject =
            when (rule.target) {
                RateLimiterProperties.Target.IP -> request.remoteAddr
            }

        return "rl:${rule.name}:${rule.target}:$subject"
    }

    private fun bucketConfig(requestsPerMinute: Int): BucketConfiguration {
        val bandwidth =
            Bandwidth
                .builder()
                .capacity(requestsPerMinute.toLong())
                .refillIntervally(requestsPerMinute.toLong(), Duration.ofMinutes(1))
                .build()

        return BucketConfiguration.builder().addLimit(bandwidth).build()
    }
}
