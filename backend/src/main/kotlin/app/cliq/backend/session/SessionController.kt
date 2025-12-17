package app.cliq.backend.session

import app.cliq.backend.exception.EmailNotVerifiedException
import app.cliq.backend.exception.InvalidEmailOrPasswordException
import app.cliq.backend.session.auth.JwtService
import app.cliq.backend.session.factory.SessionFactory
import app.cliq.backend.session.params.SessionCreationParams
import app.cliq.backend.session.response.SessionResponse
import app.cliq.backend.user.UserRepository
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/session")
@Tag(name = "Session", description = "Session management")
class SessionController(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
    private val sessionFactory: SessionFactory,
    private val jwtService: JwtService,
) {
    @PostMapping
    @Operation(summary = "Login/Create a session")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "201",
                description = "Session successfully created",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        schema = Schema(implementation = SessionResponse::class),
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
    fun createSession(
        @Valid @RequestBody sessionCreationParams: SessionCreationParams,
    ): ResponseEntity<SessionResponse> {
        val user =
            userRepository.findUserByEmail(sessionCreationParams.email)
                ?: throw InvalidEmailOrPasswordException()

        if (!user.isEmailVerified()) throw EmailNotVerifiedException()

        if (!passwordEncoder.matches(
                sessionCreationParams.password,
                user.password,
            )
        ) {
            throw InvalidEmailOrPasswordException()
        }

        val session = sessionFactory.createFromCreationParams(sessionCreationParams, user)
        val token = jwtService.generate(session)
        val response = SessionResponse.fromSession(session, token)

        return ResponseEntity.status(HttpStatus.CREATED).body(response)
    }
}
