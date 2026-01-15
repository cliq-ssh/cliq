package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class LocalLoginDisabledException : ApiException(HttpStatus.FORBIDDEN, ErrorCode.LOCAL_LOGIN_DISABLED)
