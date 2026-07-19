package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class InvalidAuthExchangeCodeException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.INVALID_AUTH_EXCHANGE_CODE)
