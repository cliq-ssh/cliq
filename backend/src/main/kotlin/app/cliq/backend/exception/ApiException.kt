package app.cliq.backend.exception

import app.cliq.backend.api.error.ErrorCode
import org.springframework.http.HttpStatus
import org.springframework.web.server.ResponseStatusException

open class ApiException(
    val statusCode: HttpStatus,
    val errorCode: ErrorCode,
    val details: Any? = null,
    cause: Throwable? = null,
) : ResponseStatusException(statusCode, errorCode.description, cause)
