package app.cliq.backend.error

import app.cliq.backend.api.error.exception.ApiException
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.stereotype.Service
import org.springframework.web.bind.MethodArgumentNotValidException

@Service
class ErrorResponseFactory {
    private val logger = LoggerFactory.getLogger(this::class.java)

    fun handleMethodArgumentNotValidException(
        exception: MethodArgumentNotValidException,
    ): ResponseEntity<ErrorResponse> =
        mapErrorResponseToResponseEntity(mapMethodArgumentNotValidExceptionToErrorResponse(exception))

    fun handleApiException(apiException: ApiException): ResponseEntity<ErrorResponse> =
        mapErrorResponseToResponseEntity(ErrorResponse.fromApiException(apiException))

    fun mapMethodArgumentNotValidExceptionToErrorResponse(exception: MethodArgumentNotValidException): ErrorResponse {
        val fieldErrors =
            exception.bindingResult.fieldErrors.map { error ->
                mapOf(
                    "field" to error.field,
                    "message" to (error.defaultMessage ?: "Invalid value"),
                    "rejectedValue" to error.rejectedValue,
                )
            }

        return ErrorResponse(
            statusCode = HttpStatus.BAD_REQUEST,
            errorCode = ErrorCode.VALIDATION_ERROR,
            details =
                mapOf(
                    "validationErrors" to fieldErrors,
                    "totalErrors" to exception.bindingResult.errorCount,
                ),
        )
    }

    fun mapErrorResponseToResponseEntity(errorResponse: ErrorResponse): ResponseEntity<ErrorResponse> {
        if (errorResponse.statusCode.is2xxSuccessful) {
            logger.warn("Returning error with a successful status code. {}", errorResponse)
        }
        if (errorResponse.statusCode.is5xxServerError) {
            logger.warn("Returning 5xx server error code. {}", errorResponse)
        }

        return ResponseEntity.status(errorResponse.statusCode).body(errorResponse)
    }
}
