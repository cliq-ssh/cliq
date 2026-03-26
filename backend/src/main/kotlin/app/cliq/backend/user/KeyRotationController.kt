package app.cliq.backend.user

import app.cliq.backend.exception.EmailNotFoundOrValidException
import app.cliq.backend.user.annotation.UserController
import app.cliq.backend.user.params.StartKeyRotationParams
import app.cliq.backend.user.params.VerifyKeyRotationParams
import app.cliq.backend.user.service.KeyRotationService
import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.media.Content
import io.swagger.v3.oas.annotations.responses.ApiResponse
import io.swagger.v3.oas.annotations.responses.ApiResponses
import jakarta.validation.Valid
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping

@UserController
@RequestMapping("/api/user/key-rotation")
class KeyRotationController(
    private val userRepository: UserRepository,
    private val keyRotationService: KeyRotationService,
) {
    @PostMapping("/start")
    @Operation(summary = "Start the key rotation process by sending a code to the user's email")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "204",
                description = "Key rotation code successfully sent",
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid E-Mail or email not verified",
                content = [Content()],
            ),
        ],
    )
    fun startKeyRotation(@Valid @RequestBody params: StartKeyRotationParams): ResponseEntity<Void> {
        // Returning 204 even if the user does not exist is intentional to not leak
        val user = userRepository.findByEmail(params.email) ?: return ResponseEntity.noContent().build()

        if (!user.isUsable()) {
            throw EmailNotFoundOrValidException()
        }

        keyRotationService.sendKeyRotationEmail(user)

        return ResponseEntity.noContent().build()
    }

    @PostMapping("/verify")
    @Operation(summary = "Verify the key rotation code and apply new encryption key and SRP parameters")
    @ApiResponses(
        value = [
            ApiResponse(
                responseCode = "200",
                description = "Key rotation successfully completed",
                content = [Content()],
            ),
            ApiResponse(
                responseCode = "400",
                description = "Invalid code, expired code, or invalid parameters",
                content = [Content()],
            ),
        ],
    )
    fun verifyKeyRotation(@Valid @RequestBody params: VerifyKeyRotationParams): ResponseEntity<Void> {
        val user = userRepository.findByEmail(params.email)
            ?: throw EmailNotFoundOrValidException()

        keyRotationService.verifyKeyRotationCode(
            user,
            params.code,
            params.dataEncryptionKey,
            params.srpSalt,
            params.srpVerifier,
            params.vault,
        )

        return ResponseEntity.noContent().build()
    }
}
