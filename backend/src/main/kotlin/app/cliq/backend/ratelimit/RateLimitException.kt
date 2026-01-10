package app.cliq.backend.ratelimit

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ResponseStatus(HttpStatus.TOO_MANY_REQUESTS)
class RateLimitException(
    val retryAfterSeconds: Long,
    message: String? = null,
) : RuntimeException(message)
