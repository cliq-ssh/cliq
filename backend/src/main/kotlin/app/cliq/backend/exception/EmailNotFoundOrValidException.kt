package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class EmailNotFoundOrValidException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.EMAIL_NOT_FOUND_OR_VALID)
