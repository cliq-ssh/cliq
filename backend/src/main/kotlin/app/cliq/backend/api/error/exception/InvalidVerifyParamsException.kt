package app.cliq.backend.api.error.exception

import app.cliq.backend.api.error.ErrorCode
import org.springframework.http.HttpStatus

class InvalidVerifyParamsException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.INVALID_VERIFY_PARAMS)
