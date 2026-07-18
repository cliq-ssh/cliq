package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class InvalidOidcCallbackTokenException : ApiException(HttpStatus.BAD_REQUEST, ErrorCode.INVALID_OIDC_CALLBACK_TOKEN)
