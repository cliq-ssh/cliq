package sh.cliq.backend.exception

import org.springframework.http.HttpStatus
import sh.cliq.backend.error.ApiException
import sh.cliq.backend.error.ErrorCode

class InvalidKeyRotationParamsException(details: String) :
    ApiException(HttpStatus.BAD_REQUEST, ErrorCode.INVALID_VERIFY_PARAMS, details = details)
