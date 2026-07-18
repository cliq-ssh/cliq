package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class InvalidEmailException :
    ApiException(
        statusCode = HttpStatus.BAD_REQUEST,
        errorCode = ErrorCode.USER_WITH_EMAIL_NOT_FOUND,
    )
