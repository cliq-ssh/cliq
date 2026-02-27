package app.cliq.backend.vault

import app.cliq.backend.annotations.Authenticated
import app.cliq.backend.session.Session
import app.cliq.backend.vault.factory.VaultFactory
import app.cliq.backend.vault.params.VaultParams
import app.cliq.backend.vault.view.VaultView
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
@RequestMapping("/api/vault")
@Tag(name = "Vault", description = "Vault management")
class VaultController(
    private val vaultFactory: VaultFactory,
    private val repository: VaultRepository,
) {
    @Authenticated
    @PutMapping
    @Operation(summary = "Insert or update vault")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Successfully updated vault",
            ),
        ],
    )
    fun put(
        @AuthenticationPrincipal session: Session,
        @RequestBody vaultParams: VaultParams,
    ): ResponseEntity<Void> {
        val user = session.user
        val existingConfig = repository.getByUser(user)

        if (existingConfig == null) {
            val config = vaultFactory.createFromParams(vaultParams, user)

            repository.save(config)
        } else {
            val config =
                vaultFactory.updateFromParams(
                    existingConfig,
                    vaultParams,
                    user,
                )

            repository.save(config)
        }

        return ResponseEntity.ok().build()
    }

    @Authenticated
    @GetMapping
    @Operation(summary = "Get's you the current vault.")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Successfully retrieved the vault.",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        schema = Schema(implementation = VaultView::class),
                    ),
                ],
            ),
        ],
    )
    fun get(
        @AuthenticationPrincipal session: Session,
    ): ResponseEntity<VaultView> {
        val user = session.user
        val vault = repository.getByUser(user) ?: return ResponseEntity.notFound().build()

        val view = VaultView(vault.encryptedConfig, vault.version, vault.updatedAt, vault.updatedAt)

        return ResponseEntity.ok(view)
    }

    @Authenticated
    @GetMapping("/last-updated")
    @Operation(summary = "Get's you when the vault was last updated")
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
