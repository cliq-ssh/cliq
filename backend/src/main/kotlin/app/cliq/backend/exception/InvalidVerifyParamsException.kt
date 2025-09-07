package app.cliq.backend.exception

import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class InvalidVerifyParamsException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.INVALID_VERIFY_PARAMS)
