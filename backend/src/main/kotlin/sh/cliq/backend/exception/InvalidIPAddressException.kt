package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class InvalidIPAddressException : ApiException(HttpStatus.FORBIDDEN, ErrorCode.INVALID_IP_ADDRESS)
