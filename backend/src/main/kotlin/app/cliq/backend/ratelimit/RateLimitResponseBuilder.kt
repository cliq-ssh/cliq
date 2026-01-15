package app.cliq.backend.ratelimit

import app.cliq.backend.error.ErrorCode
import app.cliq.backend.error.ErrorResponse
import app.cliq.backend.utils.HttpUtils
import jakarta.servlet.http.HttpServletResponse
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.stereotype.Service

@Service
class RateLimitResponseBuilder(
    private val httpUtils: HttpUtils,
) {
    fun buildResponse(
        response: HttpServletResponse,
        retryAfterSeconds: Long,
    ) {
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
