package app.cliq.backend.vault.view

import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime

@Schema
data class VaultView(
    val configuration: String,
    val version: String,
    val updatedAt: OffsetDateTime,
    val createdAt: OffsetDateTime,
)
