package app.cliq.backend.userconfig.params

import io.swagger.v3.oas.annotations.media.Schema

@Schema
data class ConfigurationParams(
    @Schema(description = "The encrypted user configuration")
    val configuration: String,
)
