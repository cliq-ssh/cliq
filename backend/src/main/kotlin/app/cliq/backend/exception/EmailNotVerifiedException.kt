package app.cliq.backend.exception

import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class EmailNotVerifiedException :
    ApiException(
        statusCode = HttpStatus.BAD_REQUEST,
        errorCode = ErrorCode.EMAIL_NOT_VERIFIED,
    )
