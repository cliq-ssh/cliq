package app.cliq.backend.ratelimit

import app.cliq.backend.error.ErrorCode
import app.cliq.backend.error.ErrorResponse
import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class RateLimitAdvice {
    @ExceptionHandler(RateLimitException::class)
    fun handleRateLimitException(e: RateLimitException): ResponseEntity<ErrorResponse> {
        val statusCode = HttpStatus.TOO_MANY_REQUESTS
        val errorCode = ErrorCode.fromRateLimitException(e)
        val response =
            ErrorResponse(
                statusCode = statusCode,
                errorCode = errorCode,
            )

        return ResponseEntity
            .status(statusCode)
            .header(HttpHeaders.RETRY_AFTER, e.retryAfterSeconds.toString())
            .body(response)
    }
}
