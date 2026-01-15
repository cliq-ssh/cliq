package app.cliq.backend.auth

import app.cliq.backend.auth.annotation.AuthController
import app.cliq.backend.session.Session
import app.cliq.backend.session.SessionRepository
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestMapping

@AuthController
@RequestMapping("/api/auth")
class AuthController(
    private val sessionRepository: SessionRepository,
) {
    @PostMapping("/logout")
    @Operation(summary = "Logs out the authenticated user and deletes the current session.")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "204",
                description = "User successfully logged out",
                content = [Content()],
            ),
            ApiResponse(
                responseCode = "401",
                description = "Unauthorized",
                content = [Content()],
            ),
        ],
    )
    private fun logout(
        @AuthenticationPrincipal session: Session,
    ): ResponseEntity<Void> {
        sessionRepository.delete(session)

        return ResponseEntity.noContent().build()
    }
}
