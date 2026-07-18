package sh.cliq.backend.user.params

import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotEmpty
import sh.cliq.backend.constants.EXAMPLE_EMAIL

@Schema
data class ResendVerificationEmailParams(
    @field:Schema(example = EXAMPLE_EMAIL) @field:Email @field:NotEmpty val email: String,
)
