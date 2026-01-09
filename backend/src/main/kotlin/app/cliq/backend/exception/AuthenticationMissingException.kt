package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class AuthenticationMissingException : ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.AUTHENTICATION_MISSING)
