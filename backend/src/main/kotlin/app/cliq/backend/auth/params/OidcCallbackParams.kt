package app.cliq.backend.auth.params

import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.NotEmpty

@Schema
data class OidcCallbackParams(
    @field:NotEmpty
    val oidcCallbackToken: String,
)
