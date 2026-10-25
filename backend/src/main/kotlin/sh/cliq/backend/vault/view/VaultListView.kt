package sh.cliq.backend.vault.view

import io.swagger.v3.oas.annotations.media.Schema
import sh.cliq.backend.vault.VaultData
import java.time.OffsetDateTime
import java.util.UUID

/**
 * A view of the vault data for listing purposes.
 * This should be used when a vault is being listed without retrieving the full vault data.
 *
 * @property id The unique identifier of the vault.
 * @property version The version of the vault data.
 * @property updatedAt The timestamp when the vault was last updated.
 * @property createdAt The timestamp when the vault was created.
 */
@Schema
data class VaultListView(
    val id: UUID,
    val version: String,
    val updatedAt: OffsetDateTime,
    val createdAt: OffsetDateTime,
) {
    companion object {
        fun fromVault(vault: VaultData): VaultListView = VaultListView(
            id = vault.id,
            version = vault.version,
            updatedAt = vault.updatedAt,
            createdAt = vault.createdAt,
        )
    }
}
