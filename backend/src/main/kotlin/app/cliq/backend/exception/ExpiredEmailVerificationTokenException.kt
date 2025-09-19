package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class ExpiredEmailVerificationTokenException :
    ApiException(HttpStatus.FORBIDDEN, ErrorCode.EMAIL_VERIFICATION_TOKEN_EXPIRED)
