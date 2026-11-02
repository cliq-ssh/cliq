package sh.cliq.backend.vault.params

import io.swagger.v3.oas.annotations.media.Schema

@Schema
open class VaultParams(
    @Schema(description = "The encrypted user configuration")
    val configuration: String,
    val version: String,
)
