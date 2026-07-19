package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class InternalServerErrorException : ApiException(HttpStatus.INTERNAL_SERVER_ERROR, ErrorCode.UNKNOWN_ERROR)
