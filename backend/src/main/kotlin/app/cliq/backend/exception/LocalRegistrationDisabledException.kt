package app.cliq.backend.exception

import app.cliq.backend.error.ApiException
import app.cliq.backend.error.ErrorCode
import org.springframework.http.HttpStatus

class LocalRegistrationDisabledException : ApiException(HttpStatus.FORBIDDEN, ErrorCode.LOCAL_REGISTRATION_DISABLED)
