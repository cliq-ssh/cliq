package app.cliq.backend.exception

import app.cliq.backend.api.error.ErrorCode
import org.springframework.http.HttpStatus

class InvalidResetParamsException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.INVALID_RESET_PARAMS)
