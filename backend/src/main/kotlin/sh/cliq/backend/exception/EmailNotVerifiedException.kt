package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class EmailNotVerifiedException :
    ApiException(
        statusCode = HttpStatus.BAD_REQUEST,
        errorCode = ErrorCode.EMAIL_NOT_VERIFIED,
    )
