package app.cliq.backend.user.params

import app.cliq.backend.docs.EXAMPLE_EMAIL
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotEmpty

@Schema
data class VerifyParams(
    @field:Schema(example = EXAMPLE_EMAIL) @field:Email @field:NotEmpty val email: String,
    @field:NotEmpty val verificationToken: String,
)
