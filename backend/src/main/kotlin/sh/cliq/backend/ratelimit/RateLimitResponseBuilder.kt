package sh.cliq.backend.ratelimit

import jakarta.servlet.http.HttpServletResponse
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service
import sh.cliq.backend.error.ErrorCode
import sh.cliq.backend.error.ErrorResponse
import sh.cliq.backend.utils.HttpUtils

@RateLimiterFeature
@Service
class RateLimitResponseBuilder(private val httpUtils: HttpUtils) {
    fun buildResponse(response: HttpServletResponse, retryAfterSeconds: Long) {
        val errorResponse =
            ErrorResponse(
                statusCode = HttpStatus.TOO_MANY_REQUESTS,
                errorCode = ErrorCode.RATE_LIMIT_EXCEEDED,
            )

        httpUtils.setErrorResponse(
            response,
            errorResponse,
        )
        response.setHeader(HttpHeaders.RETRY_AFTER, retryAfterSeconds.toString())
    }
}
