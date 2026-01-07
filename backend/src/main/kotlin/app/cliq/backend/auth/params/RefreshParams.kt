package app.cliq.backend.auth.params

import io.swagger.v3.oas.annotations.media.Schema

@Schema
data class RefreshParams(
    val refreshToken: String,
)
