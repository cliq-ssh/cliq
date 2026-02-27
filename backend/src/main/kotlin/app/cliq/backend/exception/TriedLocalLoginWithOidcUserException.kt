package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class TriedLocalLoginWithOidcUserException :
    ApiException(HttpStatus.FORBIDDEN, ErrorCode.TRIED_LOCAL_LOGIN_WITH_OIDC_USER)
