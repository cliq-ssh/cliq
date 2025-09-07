package app.cliq.backend.exception

import app.cliq.backend.api.error.ErrorCode
import org.springframework.http.HttpStatus

class EmailAlreadyVerifiedException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.EMAIL_ALREADY_VERIFIED)
