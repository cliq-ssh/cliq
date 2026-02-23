package app.cliq.backend.auth

import app.cliq.backend.auth.annotation.AuthController
import app.cliq.backend.auth.params.login.LoginFinishParams
import app.cliq.backend.auth.params.login.LoginStartParams
import app.cliq.backend.auth.service.JwtService
import app.cliq.backend.auth.service.SrpService
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.auth.view.login.LoginFinishResponse
import app.cliq.backend.auth.view.login.LoginStartResponse
import app.cliq.backend.config.properties.AuthProperties
import app.cliq.backend.exception.EmailNotVerifiedException
import app.cliq.backend.exception.InvalidEmailException
import app.cliq.backend.exception.LocalLoginDisabledException
import app.cliq.backend.exception.TriedLocalLoginWithOidcUserException
import app.cliq.backend.user.UserRepository
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
@RequestMapping("/api/auth/login")
class LocalLoginController(
    private val authProperties: AuthProperties,
    private val srpService: SrpService,
    private val userRepository: UserRepository,
    private val jwtService: JwtService,
) {
    @PostMapping("/start")
    @Operation(summary = "Starts the login process")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Started log in process.",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        schema = Schema(implementation = LoginStartResponse::class),
                    ),
                ],
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid input",
                content = [Content()],
            ),
            ApiResponse(
                responseCode = "403",
                description = "Login with local authentication has been disabled or OIDC User tried.",
                content = [Content()],
            ),
        ],
    )
    fun startLogin(
        @Valid @RequestBody loginStartParams: LoginStartParams,
    ): ResponseEntity<LoginStartResponse> {
        if (!authProperties.local.login) {
            throw LocalLoginDisabledException()
        }

        val user = userRepository.findByEmail(loginStartParams.email) ?: throw InvalidEmailException()
        if (!user.isUsable()) throw EmailNotVerifiedException()
        if (user.isOidcUser()) throw TriedLocalLoginWithOidcUserException()

        val view = srpService.startAuthenticationProcess(user, loginStartParams)

        return ResponseEntity.ok(view)
    }

    @PostMapping("/finish")
    @Operation(summary = "Finishes the login process")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Finished log in process.",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                    ),
                ],
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid input",
                content = [Content()],
            ),
            ApiResponse(
                responseCode = "403",
                description = "Login with local authentication has been disabled.",
                content = [Content()],
            ),
        ],
    )
    fun finishLogin(
        @Valid @RequestBody loginFinishParams: LoginFinishParams,
    ): ResponseEntity<LoginFinishResponse> {
        if (!authProperties.local.login) {
            throw LocalLoginDisabledException()
        }

        val (email, publicM2) = srpService.finishAuthenticationProcess(loginFinishParams)
        val user = userRepository.findByEmail(email) ?: throw InvalidEmailException()

        val tokenPair = jwtService.generateJwtTokenPair(loginFinishParams, user)
        val tokenResponse = TokenResponse.fromTokenPair(tokenPair)
        val loginResponse = LoginFinishResponse(publicM2, tokenResponse, user.dataEncryptionKey)

        return ResponseEntity.ok(loginResponse)
    }
}
