package app.cliq.backend.userconfig

import app.cliq.backend.session.Authenticated
import app.cliq.backend.session.Session
import app.cliq.backend.userconfig.factory.UserConfigurationFactory
import app.cliq.backend.userconfig.params.ConfigurationParams
import app.cliq.backend.userconfig.view.ConfigurationView
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.OffsetDateTime
import java.util.Optional

@RestController
@RequestMapping("/api/v1/user/configuration")
@Tag(name = "User Configuration", description = "User configuration management")
class UserConfigurationController(
    private val userConfigurationFactory: UserConfigurationFactory,
    private val repository: UserConfigurationRepository,
) {
    @Authenticated
    @PutMapping
    @Operation(summary = "Insert or update user configuration")
    fun put(
        @AuthenticationPrincipal session: Session,
        @RequestBody configurationParams: ConfigurationParams,
    ): ResponseEntity<Void> {
        val existingConfig = repository.getByUser(session.user)

        if (existingConfig == null) {
            val config = userConfigurationFactory.createFromParams(configurationParams, session.user)

            repository.save(config)
        } else {
            val config =
                userConfigurationFactory.updateFromParams(
                    existingConfig,
                    configurationParams,
                    session.user,
                )

            repository.save(config)
        }

        return ResponseEntity.ok().build()
    }

    @Authenticated
    @GetMapping
    @Operation(summary = "Get's you the current configuration.")
    fun get(
        @AuthenticationPrincipal session: Session,
    ): ResponseEntity<ConfigurationView> {
        val config = repository.getByUser(session.user) ?: return ResponseEntity.notFound().build()

        val view = ConfigurationView(config.encryptedConfig, config.updatedAt, config.updatedAt)

        return ResponseEntity.ok(view)
    }

    @Authenticated
    @GetMapping("/last-updated")
    @Operation(summary = "Get's you when the config was last updated")
    fun getUpdatedAt(
        @AuthenticationPrincipal session: Session,
    ): ResponseEntity<OffsetDateTime> {
        val updatedAt = repository.getUpdatedAtByUser(session.user)

        return ResponseEntity.ok(updatedAt)
    }
}
