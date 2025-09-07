package app.cliq.backend.exception

import app.cliq.backend.api.error.ErrorCode
import org.springframework.http.HttpStatus

class PasswordResetTokenNotFound : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.PASSWORD_RESET_TOKEN_NOT_FOUND)
