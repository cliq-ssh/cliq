package app.cliq.backend.auth

import app.cliq.backend.auth.annotation.AuthController
import app.cliq.backend.auth.params.LoginParams
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.auth.service.JwtService
import app.cliq.backend.auth.view.LoginResponse
import app.cliq.backend.auth.view.UserResponse
import app.cliq.backend.exception.EmailNotVerifiedException
import app.cliq.backend.exception.InvalidEmailOrPasswordException
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.factory.UserFactory
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping

@AuthController
@RequestMapping("/api/auth")
class LocalAuthController(
    private val userRepository: UserRepository,
    private val userFactory: UserFactory,
    private val passwordEncoder: PasswordEncoder,
    private val jwtService: JwtService,
) {
    @PostMapping("/register")
    @Operation(summary = "Registers a new User for local authentication.")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "201",
                description = "User successfully registered",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        schema = Schema(implementation = UserResponse::class),
                    ),
                ],
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid input",
                content = [Content()],
            ),
//            ApiResponse(responseCode = "403", description = "Registration has been disabled"),
        ],
    )
    private fun register(
        @Valid @RequestBody registrationParams: RegistrationParams,
    ): ResponseEntity<UserResponse> {
        val user = userFactory.createFromRegistrationParams(registrationParams)

        return ResponseEntity.status(HttpStatus.CREATED).body(UserResponse.fromUser(user))
    }

    @PostMapping("/login")
    @Operation(summary = "Logs in a User using local authentication.")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "201",
                description = "Successfully logged in.",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        schema = Schema(implementation = LoginResponse::class),
                    ),
                ],
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid input",
                content = [Content()],
            ),
//          ApiResponse(responseCode = "403", description = "Login with local authentication has been disabled."),
        ],
    )
    private fun login(
        @Valid @RequestBody loginParams: LoginParams,
    ): ResponseEntity<LoginResponse> {
        val user = userRepository.findByEmail(loginParams.email) ?: throw InvalidEmailOrPasswordException()

        if (!user.isEmailVerified()) throw EmailNotVerifiedException()

        if (!passwordEncoder.matches(
                loginParams.password,
                user.password,
            )
        ) {
            throw InvalidEmailOrPasswordException()
        }

        val tokenPair = jwtService.generateJwtTokenPair(loginParams, user)
        val response = LoginResponse.fromTokenPair(tokenPair)

        return ResponseEntity.status(HttpStatus.CREATED).body(response)
    }
}
