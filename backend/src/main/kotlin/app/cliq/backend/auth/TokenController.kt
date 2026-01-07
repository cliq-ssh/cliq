package app.cliq.backend.auth

import app.cliq.backend.auth.annotation.AuthController
import app.cliq.backend.auth.jwt.RefreshToken
import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.auth.params.RefreshParams
import app.cliq.backend.auth.service.JwtService
import app.cliq.backend.auth.service.RefreshTokenService
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.exception.InvalidRefreshTokenException
import app.cliq.backend.session.SessionRepository
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

@AuthController
@RequestMapping("/api/auth/token")
class TokenController(
    private val sessionRepository: SessionRepository,
    private val jwtService: JwtService,
    private val refreshTokenService: RefreshTokenService,
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
        /*
        TODO:
            - tests if token isn't expired
            - create new session on refresh
                - this would also automatically invalidate sessions if a user hasn't logged in, in a long time
            - add tests:
                - normal flow
                - try to refresh with old token
                - try to refresh with expired token
            - add rate limits to login and refresh
         */
        var session =
            sessionRepository.findByRefreshToken(refreshParams.refreshToken) ?: throw InvalidRefreshTokenException()

        val accessToken = jwtService.generateNewAccessToken(session)
        session = refreshTokenService.rotate(session)

        val tokenPair =
            TokenPair(
                accessToken,
                RefreshToken(session.refreshToken, session.expiresAt),
                session,
            )

        return ResponseEntity.ok(TokenResponse.fromTokenPair(tokenPair))
    }
}
