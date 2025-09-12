package app.cliq.backend.exception

import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class PasswordResetTokenExpired : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.PASSWORD_RESET_TOKEN_EXPIRED)
