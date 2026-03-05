package app.cliq.backend.auth.view.login

import io.swagger.v3.oas.annotations.media.Schema

@Schema
data class LoginFinishResponse(
    // SRP
    val publicM2: String,
    // Auth Exchange
    val authExchangeCode: String,
    // Keys
    val dataEncryptionKeyUmkWrapper: String?,
)
