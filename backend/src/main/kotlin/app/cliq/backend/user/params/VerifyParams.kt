package app.cliq.backend.user.params

import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotEmpty

@Schema
data class VerifyParams(
    @field:Schema(example = EMAIL_EXAMPLE) @field:Email @field:NotEmpty val email: String,
    @field:NotEmpty val verificationToken: String,
)
