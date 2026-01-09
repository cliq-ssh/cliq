package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class InvalidJwtAccessTokenException: ApiException(HttpStatus.UNAUTHORIZED, ErrorCode.INVALID_JWT_ACCESS_TOKEN)
