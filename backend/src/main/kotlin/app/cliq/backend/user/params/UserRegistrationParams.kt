package app.cliq.backend.user.params

import app.cliq.backend.user.DEFAULT_LOCALE
import app.cliq.backend.validator.EmailOccupiedConstraint
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotEmpty
import jakarta.validation.constraints.Size

@Schema
data class UserRegistrationParams(
    @field:Schema(example = EMAIL_EXAMPLE)
    @field:Email
    @field:NotEmpty
    @field:EmailOccupiedConstraint
    val email: String,

    @field:Schema(example = EXAMPLE_PASSWORD)
    @field:NotEmpty
    @field:Size(
        min = MIN_PASSWORD_LENGTH,
        max = MAX_PASSWORD_LENGTH,
    )
    val password: String,

    @field:Schema(
        description = "An arbitrary username. Can be the user's full name",
        example = "John Doe",
    )
    @field:NotEmpty
    val username: String,

    @field:Schema(example = DEFAULT_LOCALE, defaultValue = DEFAULT_LOCALE)
    val locale: String = DEFAULT_LOCALE,
)
