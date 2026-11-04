package sh.cliq.backend.preferences.controller

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
import sh.cliq.backend.annotations.Authenticated
import sh.cliq.backend.preferences.factory.PreferencesFactory
import sh.cliq.backend.preferences.params.PreferencesPutParams
import sh.cliq.backend.preferences.repository.PreferencesRepository
import sh.cliq.backend.preferences.view.PreferencesView
import sh.cliq.backend.session.Session
import java.time.OffsetDateTime

@RestController
@RequestMapping("/api/preferences")
@Tag(name = "Preferences", description = "User preferences management")
class PreferencesController(
    private val repository: PreferencesRepository,
    private val preferencesFactory: PreferencesFactory,
) {

    @Authenticated
    @PutMapping
    @Operation(summary = "Insert or update preferences.")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Successfully updated preferences.",
            ),
        ],
    )
    fun put(
        @AuthenticationPrincipal session: Session,
        @RequestBody preferencesPutParams: PreferencesPutParams,
    ): ResponseEntity<Void> {
        val user = session.user
        val existingPreferences = repository.findByUser(user)
        if (existingPreferences == null) {
            val preferences = preferencesFactory.createFromPutParams(user, preferencesPutParams)
            repository.save(preferences)

            return ResponseEntity.ok().build()
        }

        val preferences = preferencesFactory.updateFromPutParams(existingPreferences, preferencesPutParams)
        repository.save(preferences)

        return ResponseEntity.ok().build()
    }

    @Authenticated
    @GetMapping
    @Operation(summary = "Get's you the current preferences.")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Successfully retrieved the vault.",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        schema = Schema(implementation = PreferencesView::class),
                    ),
                ],
            ),
        ],
    )
    fun get(@AuthenticationPrincipal session: Session): ResponseEntity<PreferencesView> {
        val user = session.user
        val preferences = repository.findByUser(user) ?: return ResponseEntity.notFound().build()
        val view = PreferencesView.fromPreferences(preferences)

        return ResponseEntity.ok(view)
    }

    @Authenticated
    @GetMapping("/last-updated")
    @Operation(summary = "Get's you when the preferences was last updated.")
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
    fun getUpdatedAt(@AuthenticationPrincipal session: Session): ResponseEntity<String> {
        val user = session.user
        val updatedAt = repository.getUpdatedAtByUserId(user)

        return ResponseEntity.ok(updatedAt.toString())
    }
}
