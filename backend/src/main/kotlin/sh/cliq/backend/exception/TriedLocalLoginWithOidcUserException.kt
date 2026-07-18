package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class TriedLocalLoginWithOidcUserException :
    ApiException(HttpStatus.FORBIDDEN, ErrorCode.TRIED_LOCAL_LOGIN_WITH_OIDC_USER)
