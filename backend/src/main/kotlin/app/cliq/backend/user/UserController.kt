package app.cliq.backend.user

import app.cliq.backend.user.annotation.UserController
import app.cliq.backend.user.factory.UserFactory
import app.cliq.backend.user.params.UserRegistrationParams
import app.cliq.backend.user.view.UserResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import jakarta.validation.Valid
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody

@UserController
class UserController(
    private val userFactory: UserFactory,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    @PostMapping("/register")
    @Operation(summary = "Register a new user")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "201",
                description = "User successfully created",
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
        ],
    )
    fun register(
        @Valid @RequestBody registrationParams: UserRegistrationParams,
    ): ResponseEntity<UserResponse> {
        val user = userFactory.createFromRegistrationParams(registrationParams)
        val response = UserResponse.fromUser(user)

        return ResponseEntity.status(HttpStatus.CREATED).body(response)
    }
}
