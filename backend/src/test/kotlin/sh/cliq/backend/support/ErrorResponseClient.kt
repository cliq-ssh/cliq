package sh.cliq.backend.support

import sh.cliq.backend.error.ErrorCode

data class ErrorResponseClient(val errorCode: ErrorCode, val details: Any? = null)
