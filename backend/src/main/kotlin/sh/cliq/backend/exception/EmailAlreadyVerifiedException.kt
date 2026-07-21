package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class EmailAlreadyVerifiedException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.EMAIL_ALREADY_VERIFIED)
