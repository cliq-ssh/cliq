package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class EmailVerificationTokenNotFoundException :
    ApiException(HttpStatus.BAD_REQUEST, ErrorCode.EMAIL_VERIFICATION_TOKEN_NOT_FOUND)
