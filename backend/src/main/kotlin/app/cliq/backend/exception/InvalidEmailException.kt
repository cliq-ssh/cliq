package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class InvalidEmailException :
    ApiException(
        statusCode = HttpStatus.BAD_REQUEST,
        errorCode = ErrorCode.USER_WITH_EMAIL_NOT_FOUND,
    )
