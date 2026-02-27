package app.cliq.backend.auth.view.login

import app.cliq.backend.auth.view.TokenResponse
import io.swagger.v3.oas.annotations.media.Schema

@Schema
data class LoginFinishResponse(
    // SRP
    val publicM2: String,
    // JWT
    val session: TokenResponse,
    // Keys
    val dataEncryptionKeyUmkWrapper: String?,
)
