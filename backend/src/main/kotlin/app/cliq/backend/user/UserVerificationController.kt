package app.cliq.backend.user

import app.cliq.backend.exception.EmailAlreadyVerifiedException
import app.cliq.backend.exception.ExpiredEmailVerificationTokenException
import app.cliq.backend.exception.InternalServerErrorException
import app.cliq.backend.exception.InvalidVerifyParamsException
import app.cliq.backend.user.annotation.UserController
import app.cliq.backend.user.params.ResendVerificationEmailParams
import app.cliq.backend.user.params.VerifyParams
import app.cliq.backend.user.service.UserService
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
import org.springframework.web.bind.annotation.RequestMapping

@UserController
@RequestMapping("/api/v1/user/verification")
class UserVerificationController(
    private val userRepository: UserRepository,
    private val userService: UserService,
) {
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
}
