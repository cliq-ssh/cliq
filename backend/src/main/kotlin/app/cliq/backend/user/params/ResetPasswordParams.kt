package app.cliq.backend.user.params

import app.cliq.backend.constants.EXAMPLE_EMAIL
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotEmpty

@Schema
data class ResetPasswordParams(
    @field:Schema(example = EXAMPLE_EMAIL) @field:Email @field:NotEmpty val email: String,
    @field:Schema(example = "reset-token") @field:NotBlank val resetToken: String,
)
