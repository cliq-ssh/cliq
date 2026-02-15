package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class InvalidCredentialsException : ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.INVALID_CREDENTIALS)
