package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class InvalidOidcAuthExchangeCodeException :
    ApiException(HttpStatus.BAD_REQUEST, ErrorCode.INVALID_OIDC_AUTH_EXCHANGE_CODE)
