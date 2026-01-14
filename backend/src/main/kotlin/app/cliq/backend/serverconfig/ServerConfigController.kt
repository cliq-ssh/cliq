package app.cliq.backend.serverconfig

import app.cliq.backend.constants.Features
import app.cliq.backend.constants.Oidc
import app.cliq.backend.serverconfig.view.ServerConfigResponse
import app.cliq.backend.utils.ProfileUtils
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/server/configuration")
@Tag(name = "Server Configuration", description = "Server configuration related endpoints")
class ServerConfigController(
    private val profileUtils: ProfileUtils,
) {
    @GetMapping
    @Operation(summary = "Get server configuration")
    @ApiResponse(
        responseCode = "200",
        content = [
            Content(
                mediaType = MediaType.APPLICATION_JSON_VALUE,
                schema = Schema(implementation = ServerConfigResponse::class),
            ),
        ],
    )
    fun get(): ResponseEntity<ServerConfigResponse> {
        if (profileUtils.isProfileActive(Features.OIDC)) {
            return ResponseEntity.ok().body(ServerConfigResponse(Oidc.AUTHORIZATION_ENDPOINT))
        }

        return ResponseEntity.ok().body(ServerConfigResponse())
    }
}
