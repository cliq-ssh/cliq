package sh.cliq.backend.vault.view

import io.swagger.v3.oas.annotations.media.Schema
import sh.cliq.backend.vault.VaultData
import java.time.OffsetDateTime

@Schema
data class VaultView(
    val id: String,
    val configuration: String,
    val version: String,
    val updatedAt: OffsetDateTime,
    val createdAt: OffsetDateTime,
) {
    companion object {
        fun fromVault(vault: VaultData): VaultView = VaultView(
            id = vault.id.toString(),
            configuration = vault.encryptedConfig,
            version = vault.version,
            updatedAt = vault.updatedAt,
            createdAt = vault.createdAt,
        )
    }
}
