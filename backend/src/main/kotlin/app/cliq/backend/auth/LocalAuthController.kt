package app.cliq.backend.auth

import app.cliq.backend.auth.annotation.AuthController
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.config.properties.AuthProperties
import app.cliq.backend.exception.LocalRegistrationDisabledException
import app.cliq.backend.user.factory.UserFactory
import app.cliq.backend.user.view.UserResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping

@AuthController
@RequestMapping("/api/auth")
class LocalAuthController(
    private val userFactory: UserFactory,
    private val authProperties: AuthProperties,
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
            ApiResponse(responseCode = "403", description = "Registration has been disabled"),
        ],
    )
    fun register(
        @Valid @RequestBody registrationParams: RegistrationParams,
    ): ResponseEntity<UserResponse> {
        if (!authProperties.local.registration) {
            throw LocalRegistrationDisabledException()
        }

        val user = userFactory.createFromRegistrationParams(registrationParams)

        return ResponseEntity.status(HttpStatus.CREATED).body(UserResponse.fromUser(user))
    }
}
