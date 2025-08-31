package app.cliq.backend.api.error.exception

import app.cliq.backend.api.error.ErrorCode
import org.springframework.http.HttpStatus

class EmailNotFoundOrValidException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.EMAIL_NOT_FOUND_OR_VALID)
