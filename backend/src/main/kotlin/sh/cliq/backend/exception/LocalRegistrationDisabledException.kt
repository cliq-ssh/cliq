package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class LocalRegistrationDisabledException : ApiException(HttpStatus.FORBIDDEN, ErrorCode.LOCAL_REGISTRATION_DISABLED)
