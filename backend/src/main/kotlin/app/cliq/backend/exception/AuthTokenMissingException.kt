package app.cliq.backend.exception

import app.cliq.backend.api.error.ErrorCode
import org.springframework.http.HttpStatus

class AuthTokenMissingException : ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.AUTH_TOKEN_MISSING)
