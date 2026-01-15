package app.cliq.backend.error

import com.fasterxml.jackson.annotation.JsonIgnore
import io.swagger.v3.oas.annotations.media.Schema
import org.springframework.http.HttpStatus
import org.springframework.security.authentication.AnonymousAuthenticationToken
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

        fun fromAuthenticationException(authException: AuthenticationException): ErrorResponse {
            if (authException.authenticationRequest is AnonymousAuthenticationToken) {
                return buildMissingAuthenticationTokenResponse(authException.message)
            }

            return buildInvalidJwtAccessTokenResponse(authException.message)
        }

        private fun buildInvalidJwtAccessTokenResponse(message: String?): ErrorResponse =
            ErrorResponse(
                statusCode = HttpStatus.UNAUTHORIZED,
                errorCode = ErrorCode.INVALID_JWT_ACCESS_TOKEN,
                details = message,
            )

        private fun buildMissingAuthenticationTokenResponse(message: String?): ErrorResponse =
            ErrorResponse(
                statusCode = HttpStatus.UNAUTHORIZED,
                errorCode = ErrorCode.MISSING_AUTHENTICATION_TOKEN,
                details = message,
            )
    }
}
