package app.cliq.backend.auth.params

import io.swagger.v3.oas.annotations.media.Schema

@Schema
data class AuthExchangeParams(
    @field:Schema(description = "The authorization code to exchange for a JWT")
    val code: String,
)
