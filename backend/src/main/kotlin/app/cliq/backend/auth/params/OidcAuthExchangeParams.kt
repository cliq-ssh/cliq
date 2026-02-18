package app.cliq.backend.auth.params

import io.swagger.v3.oas.annotations.media.Schema

@Schema
data class OidcAuthExchangeParams(
    @field:Schema(description = "The authorization code returned contained in the redirect URI")
    val code: String,
)
