package app.cliq.backend.auth.view.login

import io.swagger.v3.oas.annotations.media.Schema

@Schema
data class LoginStartResponse(
    val publicB: String,
    val salt: String,
    val authenticationSessionToken: String,
)
