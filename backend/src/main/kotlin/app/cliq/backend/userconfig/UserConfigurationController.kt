package app.cliq.backend.userconfig

import app.cliq.backend.annotations.Authenticated
import app.cliq.backend.session.Session
import app.cliq.backend.userconfig.factory.UserConfigurationFactory
import app.cliq.backend.userconfig.params.ConfigurationParams
import app.cliq.backend.userconfig.view.ConfigurationView
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import java.time.OffsetDateTime

@RestController
@RequestMapping("/api/user/configuration")
@Tag(name = "User Configuration", description = "User configuration management")
class UserConfigurationController(
    private val userConfigurationFactory: UserConfigurationFactory,
    private val repository: UserConfigurationRepository,
) {
    @Authenticated
    @PutMapping
    @Operation(summary = "Insert or update user configuration")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Successfully updated user configuration",
            ),
        ],
    )
    fun put(
        @AuthenticationPrincipal session: Session,
        @RequestBody configurationParams: ConfigurationParams,
    ): ResponseEntity<Void> {
        val user = session.user
        val existingConfig = repository.getByUser(user)

        if (existingConfig == null) {
            val config = userConfigurationFactory.createFromParams(configurationParams, user)

            repository.save(config)
        } else {
            val config =
                userConfigurationFactory.updateFromParams(
                    existingConfig,
                    configurationParams,
                    user,
                )

            repository.save(config)
        }

        return ResponseEntity.ok().build()
    }

    @Authenticated
    @GetMapping
    @Operation(summary = "Get's you the current configuration.")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Successfully retrieved user configuration",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        schema = Schema(implementation = ConfigurationView::class),
                    ),
                ],
            ),
        ],
    )
    fun get(
        @AuthenticationPrincipal session: Session,
    ): ResponseEntity<ConfigurationView> {
        val user = session.user
        val config = repository.getByUser(user) ?: return ResponseEntity.notFound().build()

        val view = ConfigurationView(config.encryptedConfig, config.updatedAt, config.updatedAt)

        return ResponseEntity.ok(view)
    }

    @Authenticated
    @GetMapping("/last-updated")
    @Operation(summary = "Get's you when the config was last updated")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Successfully retrieved last updated at",
                content = [
                    Content(
                        mediaType = MediaType.TEXT_PLAIN_VALUE,
                        schema = Schema(implementation = OffsetDateTime::class),
                    ),
                ],
            ),
        ],
    )
    fun getUpdatedAt(
        @AuthenticationPrincipal session: Session,
    ): ResponseEntity<String> {
        val user = session.user
        val updatedAt = repository.getUpdatedAtByUser(user)

        return ResponseEntity.ok(updatedAt.toString())
    }
}
