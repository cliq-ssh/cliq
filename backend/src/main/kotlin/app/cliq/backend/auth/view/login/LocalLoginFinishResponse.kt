package app.cliq.backend.auth.view.login

import io.swagger.v3.oas.annotations.media.Schema

@Schema
class LocalLoginFinishResponse(
    // SRP
    val publicM2: String,
    // Auth Exchange
    authExchangeCode: String,
    // Keys
    dataEncryptionKeyUmkWrapped: String?,
) : LoginFinishResponse(
    authExchangeCode,
    dataEncryptionKeyUmkWrapped,
)
