package app.cliq.backend.auth

import app.cliq.backend.auth.annotation.AuthController
import app.cliq.backend.auth.params.RefreshParams
import app.cliq.backend.auth.service.JwtResolver
import app.cliq.backend.auth.service.RefreshTokenService
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.exception.InvalidRefreshTokenException
import app.cliq.backend.exception.RefreshTokenExpiredException
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import jakarta.validation.Valid
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import java.time.Clock
import java.time.OffsetDateTime

/*
TODO:
    - add tests:
        - normal flow
        - try to refresh with old token
        - try to refresh with expired token
*/
@AuthController
@RequestMapping("/api/auth")
class TokenController(
    private val jwtResolver: JwtResolver,
    private val refreshTokenService: RefreshTokenService,
    private val clock: Clock,
) {
    @PostMapping("/refresh")
    @Operation(summary = "Refreshes JWT Access token.")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Successfully refreshed access token.",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        schema = Schema(implementation = TokenResponse::class),
                    ),
                ],
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid or expired JWT refresh token.",
                content = [Content()],
            ),
        ],
    )
    private fun refreshToken(
        @RequestBody @Valid refreshParams: RefreshParams,
    ): ResponseEntity<TokenResponse> {
        val session =
            jwtResolver.resolveSessionFromRefreshToken(refreshParams.refreshToken)
                ?: throw InvalidRefreshTokenException()
        if (session.isExpired(OffsetDateTime.now(clock))) throw RefreshTokenExpiredException()

        val tokenPair = refreshTokenService.rotate(session)

        return ResponseEntity.ok(TokenResponse.fromTokenPair(tokenPair))
    }
}
