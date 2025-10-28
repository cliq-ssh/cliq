package app.cliq.backend.userconfig.factory

import app.cliq.backend.user.User
import app.cliq.backend.userconfig.UserConfiguration
import app.cliq.backend.userconfig.params.ConfigurationParams
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class
UserConfigurationFactory(
    private val clock: Clock,
) {
    fun createFromParams(
        configurationParams: ConfigurationParams,
        user: User,
    ): UserConfiguration = create(configurationParams.configuration, user)

    fun updateFromParams(
        existingConfig: UserConfiguration,
        configurationParams: ConfigurationParams,
        user: User,
    ): UserConfiguration =
        UserConfiguration(
            user,
            configurationParams.configuration,
            existingConfig.createdAt,
            OffsetDateTime.now(clock),
            id = existingConfig.id,
        )

    fun create(
        encryptedConfig: String,
        user: User,
    ): UserConfiguration =
        UserConfiguration(
            user = user,
            encryptedConfig = encryptedConfig,
            createdAt = OffsetDateTime.now(clock),
            updatedAt = OffsetDateTime.now(clock),
        )
}
