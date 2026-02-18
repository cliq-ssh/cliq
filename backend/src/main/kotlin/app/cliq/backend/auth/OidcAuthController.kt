package app.cliq.backend.auth

import app.cliq.backend.auth.annotation.AuthController
import app.cliq.backend.auth.params.OidcAuthExchangeParams
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.oidc.service.AuthExchangeService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import jakarta.servlet.http.HttpServletRequest
import jakarta.validation.Valid
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping

@AuthController
@RequestMapping("/api/auth/oidc")
class OidcAuthController(
    private val authExchangeService: AuthExchangeService,
) {
    @PostMapping("/exchange")
    @Operation(summary = "Exchanges an OIDC auth code for a JWT Access token.")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Auth code successfully exchanged for JWT Access token",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        schema = Schema(implementation = TokenResponse::class),
                    ),
                ],
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid input",
                content = [Content()],
            ),
            ApiResponse(responseCode = "403", description = "IP Address does not match", content = [Content()]),
        ],
    )
    private fun exchange(
        @RequestBody
        @Valid
        authExchangeParams: OidcAuthExchangeParams,
        request: HttpServletRequest,
    ): ResponseEntity<TokenResponse> {
        val authExchange = authExchangeService.getValidAuthExchangeByCode(authExchangeParams.code, request)
        val tokenResponse = authExchangeService.consumeToTokenResponse(authExchange)

        return ResponseEntity.ok(tokenResponse)
    }
}
