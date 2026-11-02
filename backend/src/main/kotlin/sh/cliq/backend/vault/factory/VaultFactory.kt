package sh.cliq.backend.vault.factory

import org.springframework.stereotype.Service
import sh.cliq.backend.user.User
import sh.cliq.backend.vault.VaultData
import sh.cliq.backend.vault.params.VaultParams
import java.time.Clock
import java.time.OffsetDateTime
import java.util.UUID

@Service
class
VaultFactory(private val clock: Clock) {
    fun createFromParams(id: UUID, vaultCreationParams: VaultParams, user: User): VaultData =
        create(id, vaultCreationParams.configuration, vaultCreationParams.version, user)

    fun updateFromParams(existingConfig: VaultData, vaultParams: VaultParams, user: User): VaultData = VaultData(
        user,
        vaultParams.configuration,
        vaultParams.version,
        existingConfig.createdAt,
        OffsetDateTime.now(clock),
        id = existingConfig.id,
    )

    fun create(id: UUID, encryptedConfig: String, version: String, user: User): VaultData = VaultData(
        id = id,
        user = user,
        encryptedConfig = encryptedConfig,
        version = version,
        createdAt = OffsetDateTime.now(clock),
        updatedAt = OffsetDateTime.now(clock),
    )
}
