package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class RefreshTokenExpiredException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.REFRESH_TOKEN_EXPIRED)
