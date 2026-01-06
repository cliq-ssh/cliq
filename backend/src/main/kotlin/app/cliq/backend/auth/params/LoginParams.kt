package app.cliq.backend.auth.params

import app.cliq.backend.docs.EXAMPLE_EMAIL
import app.cliq.backend.docs.EXAMPLE_PASSWORD
import app.cliq.backend.docs.EXAMPLE_SESSION_NAME
import app.cliq.backend.docs.MAX_PASSWORD_LENGTH
import app.cliq.backend.docs.MIN_PASSWORD_LENGTH
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotEmpty
import jakarta.validation.constraints.Size

@Schema
data class LoginParams(
    @field:Schema(example = EXAMPLE_EMAIL)
    @field:Email
    @field:NotEmpty
    val email: String,
    @field:Schema(example = EXAMPLE_PASSWORD)
    @field:NotEmpty
    @field:Size(min = MIN_PASSWORD_LENGTH, max = MAX_PASSWORD_LENGTH)
    val password: String,
    @field:Schema(example = EXAMPLE_SESSION_NAME)
    val name: String? = null,
)
