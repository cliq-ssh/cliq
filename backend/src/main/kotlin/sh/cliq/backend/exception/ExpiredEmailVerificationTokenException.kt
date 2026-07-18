package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class ExpiredEmailVerificationTokenException :
    ApiException(HttpStatus.FORBIDDEN, ErrorCode.EMAIL_VERIFICATION_TOKEN_EXPIRED)
