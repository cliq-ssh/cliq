package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class InvalidIPAddressException : ApiException(HttpStatus.FORBIDDEN, ErrorCode.INVALID_IP_ADDRESS)
