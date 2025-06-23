package app.cliq.backend.api.error.exception

import app.cliq.backend.api.error.ErrorCode
import org.springframework.http.HttpStatus

class InvalidEmailOrPasswordException : ApiException(
    statusCode = HttpStatus.BAD_REQUEST,
    errorCode = ErrorCode.USER_WITH_EMAIL_NOT_FOUND,
)
