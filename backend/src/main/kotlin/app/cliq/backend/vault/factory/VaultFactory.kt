package app.cliq.backend.vault.factory

import app.cliq.backend.user.User
import app.cliq.backend.vault.VaultData
import app.cliq.backend.vault.params.VaultParams
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class
VaultFactory(
    private val clock: Clock,
) {
    fun createFromParams(
        vaultParams: VaultParams,
        user: User,
    ): VaultData = create(vaultParams.configuration, vaultParams.version, user)

    fun updateFromParams(
        existingConfig: VaultData,
        vaultParams: VaultParams,
        user: User,
    ): VaultData =
        VaultData(
            user,
            vaultParams.configuration,
            vaultParams.version,
            existingConfig.createdAt,
            OffsetDateTime.now(clock),
            id = existingConfig.id,
        )

    fun create(
        encryptedConfig: String,
        version: String,
        user: User,
    ): VaultData =
        VaultData(
            user = user,
            encryptedConfig = encryptedConfig,
            version = version,
            createdAt = OffsetDateTime.now(clock),
            updatedAt = OffsetDateTime.now(clock),
        )
}
