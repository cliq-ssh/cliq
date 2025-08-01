package app.cliq.backend.api.error

import app.cliq.backend.api.error.exception.ApiException
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class GlobalExceptionHandler(
    private val errorResponseFactory: ErrorResponseFactory
) {

    @ExceptionHandler(ApiException::class)
    fun handleApiException(apiException: ApiException): ResponseEntity<ErrorResponse> {
        return errorResponseFactory.handleApiException(apiException)
    }

    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidationException(exception: MethodArgumentNotValidException): ResponseEntity<ErrorResponse> {
        return errorResponseFactory.handleMethodArgumentNotValidException(exception)
    }
}
