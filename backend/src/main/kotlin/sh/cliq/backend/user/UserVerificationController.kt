package sh.cliq.backend.user

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
import org.springframework.web.bind.annotation.RequestMapping
import sh.cliq.backend.exception.EmailAlreadyVerifiedException
import sh.cliq.backend.exception.EmailVerificationTokenNotFoundException
import sh.cliq.backend.exception.ExpiredEmailVerificationTokenException
import sh.cliq.backend.exception.InternalServerErrorException
import sh.cliq.backend.exception.InvalidVerifyParamsException
import sh.cliq.backend.user.annotation.UserController
import sh.cliq.backend.user.params.ResendVerificationEmailParams
import sh.cliq.backend.user.params.VerifyParams
import sh.cliq.backend.user.service.UserService
import sh.cliq.backend.user.view.UserResponse

@UserController
@RequestMapping("/api/user/verification")
class UserVerificationController(private val userRepository: UserRepository, private val userService: UserService) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    @PostMapping
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
    fun verify(@Valid @RequestBody verifyParams: VerifyParams): ResponseEntity<UserResponse> {
        val user =
            userRepository.findByEmail(verifyParams.email) ?: throw InvalidVerifyParamsException()

        if (user.emailVerificationToken != verifyParams.verificationToken) {
            throw EmailVerificationTokenNotFoundException()
        }

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

    @PostMapping("/resend-email")
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
    fun resendVerificationEmail(@Valid @RequestBody params: ResendVerificationEmailParams): ResponseEntity<Void> {
        val user = userRepository.findByEmail(params.email)

        return when {
            user == null -> ResponseEntity.badRequest().build()

            user.isEmailVerified() -> ResponseEntity.badRequest().build()

            else -> {
                userService.sendVerificationEmail(user)
                ResponseEntity.noContent().build()
            }
        }
    }
}
