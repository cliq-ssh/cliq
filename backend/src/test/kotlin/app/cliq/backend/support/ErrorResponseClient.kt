package app.cliq.backend.support

import app.cliq.backend.error.ErrorCode

data class ErrorResponseClient(
    val errorCode: ErrorCode,
    val details: Any? = null,
)
