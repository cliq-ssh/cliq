package app.cliq.backend.auth.params.login

import app.cliq.backend.constants.EXAMPLE_EMAIL
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotEmpty

@Schema
data class LoginStartParams(
    @field:Schema(example = EXAMPLE_EMAIL)
    @field:Email
    @field:NotEmpty
    val email: String,
)
