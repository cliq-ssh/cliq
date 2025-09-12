package app.cliq.backend.exception

import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class InternalServerErrorException : ApiException(HttpStatus.INTERNAL_SERVER_ERROR, ErrorCode.UNKNOWN_ERROR)
