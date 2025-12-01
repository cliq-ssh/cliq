package app.cliq.backend.user

import app.cliq.backend.exception.EmailNotFoundOrValidException
import app.cliq.backend.exception.InvalidResetParamsException
import app.cliq.backend.exception.PasswordResetTokenExpired
import app.cliq.backend.user.annotation.UserController
import app.cliq.backend.user.factory.UserFactory
import app.cliq.backend.user.params.ResetPasswordParams
import app.cliq.backend.user.params.StartResetPasswordProcessParams
import app.cliq.backend.user.service.UserService
import app.cliq.backend.user.view.UserResponse
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import jakarta.validation.Valid
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping

@UserController
@RequestMapping("/api/user/password-reset")
class PasswordResetController(
    private val userRepository: UserRepository,
    private val userService: UserService,
    private val userFactory: UserFactory,
) {
    @PostMapping("/start")
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

    @PostMapping("/reset")
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
