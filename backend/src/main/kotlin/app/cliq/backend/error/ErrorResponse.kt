package app.cliq.backend.error

import com.fasterxml.jackson.annotation.JsonIgnore
import io.swagger.v3.oas.annotations.media.Schema
import org.springframework.http.HttpStatus
import org.springframework.security.core.AuthenticationException

@Schema
data class ErrorResponse(
    @JsonIgnore
    @field:Schema(hidden = true)
    val statusCode: HttpStatus,
    @field:Schema
    val errorCode: ErrorCode,
    @field:Schema(description = "An arbitrary object containing additional details about the error")
    val details: Any? = null,
) {
    companion object {
        fun fromApiException(apiException: ApiException): ErrorResponse =
            ErrorResponse(
                statusCode = apiException.statusCode,
                errorCode = apiException.errorCode,
                details = apiException.details,
            )

        fun fromAuthenticationException(authException: AuthenticationException): ErrorResponse =
            ErrorResponse(
                statusCode = HttpStatus.UNAUTHORIZED,
                errorCode = ErrorCode.INVALID_AUTH_TOKEN,
                details = authException.message,
            )
    }
}
