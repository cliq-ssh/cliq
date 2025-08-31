package app.cliq.backend.api.user

import EmailOccupiedConstraint
import app.cliq.backend.api.error.exception.EmailAlreadyVerifiedException
import app.cliq.backend.api.error.exception.EmailNotFoundOrValidException
import app.cliq.backend.api.error.exception.ExpiredEmailVerificationTokenException
import app.cliq.backend.api.error.exception.InternalServerErrorException
import app.cliq.backend.api.error.exception.InvalidResetParamsException
import app.cliq.backend.api.error.exception.InvalidVerifyParamsException
import app.cliq.backend.api.error.exception.PasswordResetTokenExpired
import app.cliq.backend.api.user.view.UserResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.media.Schema
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import io.swagger.v3.oas.annotations.tags.Tag
import jakarta.validation.Valid
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotEmpty
import jakarta.validation.constraints.Size
import org.slf4j.LoggerFactory
import org.springframework.http.HttpStatus
import org.springframework.http.MediaType
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/v1/user")
@Tag(name = "User", description = "User management")
class UserController(
    private val userFactory: UserFactory,
    private val userService: UserService,
    private val userRepository: UserRepository,
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

    @PostMapping("/verify")
    @Operation(summary = "Verify a users email address")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Email successfully verified",
                content = [
                    Content(
                        mediaType = MediaType.APPLICATION_JSON_VALUE,
                        schema = Schema(implementation = UserResponse::class),
                    ),
                ],
            ),
            ApiResponse(
                responseCode = "400",
                description = "Verification params is invalid",
                content = [
                    Content(),
                ],
            ),
            ApiResponse(
                responseCode = "403",
                description = "Verification token expired",
                content = [
                    Content(),
                ],
            ),
        ],
    )
    fun verify(
        @Valid @RequestBody verifyParams: VerifyParams,
    ): ResponseEntity<UserResponse> {
        val user =
            userRepository.findUserByEmail(verifyParams.email) ?: throw InvalidVerifyParamsException()

        if (user.isEmailVerified()) {
            throw EmailAlreadyVerifiedException()
        }

        if (user.isEmailVerificationTokenExpired()) {
            throw ExpiredEmailVerificationTokenException()
        }

        if (!user.isEmailVerificationTokenValid()) {
            logger.error("E-Mail verification token of user {} should be valid but is invalid.", user.id)

            throw InternalServerErrorException()
        }

        userService.verifyUserEmail(user)

        return ResponseEntity.status(HttpStatus.OK).body(UserResponse.fromUser(user))
    }

    @PostMapping("/resend-verification-email")
    @Operation(summary = "Resend verification email")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "204",
                description = "Verification email successfully resent",
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid E-Mail or email already verified",
                content = [Content()],
            ),
        ],
    )
    fun resendVerificationEmail(
        @Valid @RequestBody params: ResendVerificationEmailParams,
    ): ResponseEntity<Void> {
        userRepository.findUserByEmail(params.email)?.let {
            if (it.isEmailVerified()) {
                return ResponseEntity.status(HttpStatus.BAD_REQUEST).build()
            }

            userService.sendVerificationEmail(it)

            return ResponseEntity.noContent().build()
        }

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).build()
    }

    @PostMapping("/init-reset-password")
    @Operation(summary = "Start the reset password process")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "204",
                description = "Reset password email successfully sent",
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid E-Mail or email not verified",
                content = [Content()],
            ),
        ],
    )
    fun startResetPasswordProcess(
        @Valid @RequestBody params: StartResetPasswordProcessParams,
    ): ResponseEntity<Void> {
        // Returning 204 even if the user does not exist is intentional to not leak
        val user = userRepository.findUserByEmail(params.email) ?: return ResponseEntity.noContent().build()

        if (!user.isEmailVerified()) {
            throw EmailNotFoundOrValidException()
        }

        userService.sendResetPasswordEmail(user)

        return ResponseEntity.noContent().build()
    }

    @PostMapping("/reset-password")
    @Operation(summary = "Reset a users password")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Password successfully reset",
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid reset token or password",
                content = [Content()],
            ),
        ],
    )
    fun resetPassword(
        @Valid @RequestBody params: ResetPasswordParams,
    ): ResponseEntity<UserResponse> {
        val user =
            userRepository.findUserByResetTokenAndEmail(params.resetToken, params.email)
                ?: throw InvalidResetParamsException()

        if (!user.isPasswordResetTokenExpired()) {
            throw PasswordResetTokenExpired()
        }

        val newUser = userFactory.updateUserPassword(user, params.password)

        return ResponseEntity.status(HttpStatus.OK).body(UserResponse.fromUser(newUser))
    }
}

const val MIN_PASSWORD_LENGTH = 8
const val MAX_PASSWORD_LENGTH = 256

const val EMAIL_EXAMPLE = "user@example.lan"
const val EXAMPLE_PASSWORD = "CLIq123!"

@Schema
data class UserRegistrationParams(
    @field:Schema(example = EMAIL_EXAMPLE) @field:Email @field:NotEmpty @field:EmailOccupiedConstraint val email:
        String,
    @field:Schema(example = EXAMPLE_PASSWORD) @field:NotEmpty @field:Size(
        min = MIN_PASSWORD_LENGTH,
        max = MAX_PASSWORD_LENGTH,
    ) val password: String,
    @field:Schema(
        description = "An arbitrary username. Can be the user's full name",
        example = "John Doe",
    ) @field:NotEmpty val username: String,
    @field:Schema(example = DEFAULT_LOCALE, defaultValue = DEFAULT_LOCALE) val locale: String = DEFAULT_LOCALE,
)

@Schema
data class VerifyParams(
    @field:Schema(example = EMAIL_EXAMPLE) @field:Email @field:NotEmpty val email: String,
    @field:NotEmpty val verificationToken: String,
)

@Schema
data class ResendVerificationEmailParams(
    @field:Schema(example = EMAIL_EXAMPLE) @field:Email @field:NotEmpty val email: String,
)

@Schema
data class StartResetPasswordProcessParams(
    @field:Schema(example = EMAIL_EXAMPLE) @field:Email @field:NotEmpty val email: String,
)

@Schema
data class ResetPasswordParams(
    @field:Schema(example = EMAIL_EXAMPLE) @field:Email @field:NotEmpty val email: String,
    @field:Schema(example = "reset-token") @field:NotBlank val resetToken: String,
    @field:Schema(example = EXAMPLE_PASSWORD) @field:NotEmpty @field:Size(
        min = MIN_PASSWORD_LENGTH,
        max = MAX_PASSWORD_LENGTH,
    ) val password: String,
)
