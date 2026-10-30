package sh.cliq.backend.vault.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.Parameter
import io.swagger.v3.oas.annotations.media.ArraySchema
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController
import sh.cliq.backend.annotations.Authenticated
import sh.cliq.backend.session.Session
import sh.cliq.backend.vault.VaultRepository
import sh.cliq.backend.vault.factory.VaultFactory
import sh.cliq.backend.vault.params.VaultParams
import sh.cliq.backend.vault.view.PartialVaultView
import sh.cliq.backend.vault.view.VaultView
import java.time.OffsetDateTime
import java.util.UUID

@RestController
@RequestMapping("/api/vaults")
@Tag(name = "Vault", description = "Vault management")
class VaultController(private val vaultFactory: VaultFactory, private val repository: VaultRepository) {
    @Authenticated
    @GetMapping
    @Operation(summary = "List all vaults")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Successfully retrieved the list of vaults.",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        array = ArraySchema(schema = Schema(implementation = PartialVaultView::class)),
                    ),
                ],
            ),
        ],
    )
    fun list(@AuthenticationPrincipal session: Session): ResponseEntity<List<PartialVaultView>> {
        val user = session.user
        val vaults = repository.findAllByUser(user).map { PartialVaultView.fromVault(it) }

        return ResponseEntity.ok(vaults)
    }

    @Authenticated
    @PreAuthorize("@vaultAuthorization.canUpdate(#id, #session.user)")
    @PutMapping("/{id}")
    @Operation(summary = "Insert or update vault")
    @Parameter(
        name = "id",
        description = "The ID of the vault to insert or update. Should be a UUID, preferably a UUIDv7.",
        required = true,
    )
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Successfully updated vault",
            ),
        ],
    )
    fun put(
        @PathVariable id: UUID,
        @AuthenticationPrincipal session: Session,
        @RequestBody vaultParams: VaultParams,
    ): ResponseEntity<Void> {
        val user = session.user
        val existingConfig = repository.findById(id).orElse(null)

        if (existingConfig == null) {
            val config = vaultFactory.createFromParams(id, vaultParams, user)

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
    @GetMapping("/{id}")
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
    fun get(@PathVariable id: UUID, @AuthenticationPrincipal session: Session): ResponseEntity<VaultView> {
        val user = session.user
        val vault = repository.findByIdAndUser(id, user) ?: return ResponseEntity.notFound().build()

        val view = VaultView.fromVault(vault)

        return ResponseEntity.ok(view)
    }

    @Authenticated
    @GetMapping("/{id}/last-updated")
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
    fun getUpdatedAt(@PathVariable id: UUID, @AuthenticationPrincipal session: Session): ResponseEntity<String> {
        val user = session.user
        val updatedAt = repository.getUpdatedAtByIdAndUser(id, user)

        return ResponseEntity.ok(updatedAt.toString())
    }
}
