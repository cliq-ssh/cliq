package app.cliq.backend.auth.controller

import app.cliq.backend.auth.annotation.AuthController
import app.cliq.backend.auth.oidc.OidcCallbackTokenRepository
import app.cliq.backend.auth.params.OidcCallbackParams
import app.cliq.backend.auth.service.AuthExchangeService
import app.cliq.backend.auth.view.login.LoginFinishResponse
import app.cliq.backend.exception.InvalidAuthExchangeCodeException
import app.cliq.backend.exception.InvalidOidcCallbackTokenException
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
class OidcController(
    private val authExchangeService: AuthExchangeService,
    private val oidcCallbackTokenRepository: OidcCallbackTokenRepository,
) {
    @PostMapping("/callback")
    @Operation(summary = "Callback that needs to be called after a successfully oidc login.")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Successfully exchanged oidc token for auth exchange code.",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        schema = Schema(LoginFinishResponse::class),
                    ),
                ],
            ),
            ApiResponse(
                responseCode = "401",
                description = "Unauthorized",
                content = [Content()],
            ),
            ApiResponse(
                responseCode = "400",
                description = "Bad Request",
                content = [Content()],
            ),
        ],
    )
    private fun callback(
        @RequestBody
        @Valid
        params: OidcCallbackParams,
        httpServletRequest: HttpServletRequest,
    ): ResponseEntity<LoginFinishResponse> {
        val callbackToken =
            oidcCallbackTokenRepository.findByToken(params.oidcCallbackToken)
                ?: throw InvalidOidcCallbackTokenException()
        val authExchange = callbackToken.authExchange

        try {
            authExchangeService.validOrThrowAuthExchange(callbackToken.authExchange, httpServletRequest)
        } catch (_: InvalidAuthExchangeCodeException) {
            throw InvalidOidcCallbackTokenException()
        }

        val user = authExchange.user
        val response = LoginFinishResponse(authExchange.exchangeCode, user.dataEncryptionKey)

        return ResponseEntity.ok(response)
    }
}
