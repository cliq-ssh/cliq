package sh.cliq.backend.auth.params

import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotEmpty
import sh.cliq.backend.constants.EXAMPLE_EMAIL
import sh.cliq.backend.constants.EXAMPLE_SRP_SALT
import sh.cliq.backend.constants.EXAMPLE_SRP_VERIFIER
import sh.cliq.backend.constants.EXAMPLE_USERNAME
import sh.cliq.backend.user.DEFAULT_LOCALE
import sh.cliq.backend.user.validator.EmailOccupiedConstraint

@Schema
data class RegistrationParams(
    @field:Schema(example = EXAMPLE_EMAIL)
    @field:Email
    @field:NotEmpty
    @field:EmailOccupiedConstraint
    val email: String,
    @field:Schema(
        description = "An arbitrary username. Can be the user's full name",
        example = EXAMPLE_USERNAME,
    )
    @field:NotEmpty
    val username: String,
    @field:Schema(description = "The data encryption key encoded in Base64")
    val dataEncryptionKey: String,
    @field:Schema(example = EXAMPLE_SRP_SALT, description = "The salt hex encoded")
    val srpSalt: String,
    @field:Schema(example = EXAMPLE_SRP_VERIFIER, description = "The verifier hex encoded")
    @field:NotEmpty
    val srpVerifier: String,
    @field:Schema(example = DEFAULT_LOCALE, defaultValue = DEFAULT_LOCALE)
    val locale: String = DEFAULT_LOCALE,
)
