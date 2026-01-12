package app.cliq.backend.user

import app.cliq.backend.annotations.Authenticated
import app.cliq.backend.session.Session
import app.cliq.backend.user.annotation.UserController
import app.cliq.backend.user.view.UserResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping

@UserController
@RequestMapping("/api/user")
class UserController {
    @GetMapping("/me")
    @Authenticated
    @Operation(summary = "Gets information about the currently authenticated user")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Reset password email successfully sent",
                content = [Content(schema = Schema(implementation = UserResponse::class))],
            ),
        ],
    )
    fun me(
        @AuthenticationPrincipal session: Session,
    ): ResponseEntity<UserResponse> = ResponseEntity.ok().body(UserResponse.fromUser(session.user))
}
