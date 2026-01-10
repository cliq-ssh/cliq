package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class RefreshTokenExpiredException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.REFRESH_TOKEN_EXPIRED)
