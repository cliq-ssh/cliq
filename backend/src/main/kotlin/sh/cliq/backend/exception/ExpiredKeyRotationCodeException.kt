package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class ExpiredKeyRotationCodeException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.KEY_ROTATION_TOKEN_EXPIRED)
