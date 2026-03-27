package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class ExpiredKeyRotationCodeException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.KEY_ROTATION_TOKEN_EXPIRED)
