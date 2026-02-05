package app.cliq.backend.vault.params

import io.swagger.v3.oas.annotations.media.Schema

@Schema
data class VaultParams(
    @Schema(description = "The encrypted user configuration")
    val configuration: String,
    val version: String,
)
