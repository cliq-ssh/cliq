package app.cliq.backend.auth.view.login

import io.swagger.v3.oas.annotations.media.Schema

@Schema
open class LoginFinishResponse(
    // Auth Exchange
    val authExchangeCode: String,
    // Keys
    val dataEncryptionKeyUmkWrapped: String?,
)
