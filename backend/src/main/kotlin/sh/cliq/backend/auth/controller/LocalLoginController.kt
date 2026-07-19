package sh.cliq.backend.auth.controller

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
import sh.cliq.backend.auth.annotation.AuthController
import sh.cliq.backend.auth.factory.AuthExchangeFactory
import sh.cliq.backend.auth.params.login.LoginFinishParams
import sh.cliq.backend.auth.params.login.LoginStartParams
import sh.cliq.backend.auth.service.SrpService
import sh.cliq.backend.auth.view.login.LocalLoginFinishResponse
import sh.cliq.backend.auth.view.login.LoginStartResponse
import sh.cliq.backend.config.properties.AuthProperties
import sh.cliq.backend.exception.EmailNotVerifiedException
import sh.cliq.backend.exception.InvalidEmailException
import sh.cliq.backend.exception.LocalLoginDisabledException
import sh.cliq.backend.exception.TriedLocalLoginWithOidcUserException
import sh.cliq.backend.user.UserRepository

@AuthController
@RequestMapping("/api/auth/login")
class LocalLoginController(
    private val authProperties: AuthProperties,
    private val srpService: SrpService,
    private val userRepository: UserRepository,
    private val authExchangeFactory: AuthExchangeFactory,
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
    fun startLogin(@Valid @RequestBody loginStartParams: LoginStartParams): ResponseEntity<LoginStartResponse> {
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
                        schema = Schema(LocalLoginFinishResponse::class),
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
        httpRequest: HttpServletRequest,
    ): ResponseEntity<LocalLoginFinishResponse> {
        if (!authProperties.local.login) {
            throw LocalLoginDisabledException()
        }

        val (email, publicM2) = srpService.finishAuthenticationProcess(loginFinishParams)
        val user = userRepository.findByEmail(email) ?: throw InvalidEmailException()

        val authExchange = authExchangeFactory.createFromRequestAndUser(httpRequest, user)
        val loginResponse = LocalLoginFinishResponse(publicM2, authExchange.exchangeCode, user.dataEncryptionKey)

        return ResponseEntity.ok(loginResponse)
    }
}
