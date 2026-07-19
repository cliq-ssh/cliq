package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class EmailNotFoundOrValidException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.EMAIL_NOT_FOUND_OR_VALID)
