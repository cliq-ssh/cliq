package sh.cliq.backend.preferences.params

import io.swagger.v3.oas.annotations.media.Schema

@Schema
data class PreferencesPutParams(
    @Schema(description = "The encrypted user preferences.")
    val preferences: String,
    val version: String,
)
