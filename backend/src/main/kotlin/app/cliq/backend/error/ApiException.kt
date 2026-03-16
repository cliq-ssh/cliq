package app.cliq.backend.error

import io.swagger.v3.oas.annotations.media.Schema
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException

@Schema(description = "API Exception")
open class ApiException(
    val statusCode: HttpStatus,
    val errorCode: ErrorCode,
    val details: Any? = null,
    cause: Throwable? = null,
) : ResponseStatusException(statusCode, errorCode.description, cause)
