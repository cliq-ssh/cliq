package app.cliq.backend.user.params

import app.cliq.backend.constants.EXAMPLE_EMAIL
import app.cliq.backend.constants.EXAMPLE_PASSWORD
import app.cliq.backend.constants.MAX_PASSWORD_LENGTH
import app.cliq.backend.constants.MIN_PASSWORD_LENGTH
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotEmpty
import jakarta.validation.constraints.Size

@Schema
data class ResetPasswordParams(
    @field:Schema(example = EXAMPLE_EMAIL) @field:Email @field:NotEmpty val email: String,
    @field:Schema(example = "reset-token") @field:NotBlank val resetToken: String,
    @field:Schema(example = EXAMPLE_PASSWORD) @field:NotEmpty @field:Size(
        min = MIN_PASSWORD_LENGTH,
        max = MAX_PASSWORD_LENGTH,
    ) val password: String,
)
