package app.cliq.backend.error

import com.fasterxml.jackson.annotation.JsonIgnore
import io.swagger.v3.oas.annotations.media.Schema
import org.springframework.http.HttpStatus

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
    }
}
