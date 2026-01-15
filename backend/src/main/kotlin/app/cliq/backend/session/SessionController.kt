package app.cliq.backend.session

import app.cliq.backend.annotations.Authenticated
import app.cliq.backend.session.view.SessionResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.tags.Tag
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@Tag(name = "Session", description = "Session management")
@RequestMapping("/api/session")
class SessionController {
    @Operation(summary = "Get the currently authenticated user's session")
    @ApiResponse(
        responseCode = "200",
        description = "Successfully retrieved current session",
        content = [
            Content(
                mediaType = MediaType.APPLICATION_JSON_VALUE,
                schema = Schema(implementation = SessionResponse::class),
            ),
        ],
    )
    @GetMapping("/current")
    @Authenticated
    fun current(
        @AuthenticationPrincipal session: Session,
    ): ResponseEntity<SessionResponse> = ResponseEntity.ok(SessionResponse.fromSession(session))
}
