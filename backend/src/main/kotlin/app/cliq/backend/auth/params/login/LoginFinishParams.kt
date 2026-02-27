package app.cliq.backend.auth.params.login

import app.cliq.backend.constants.EXAMPLE_SESSION_NAME
import io.swagger.v3.oas.annotations.media.Schema

@Schema
data class LoginFinishParams(
    // SRP
    val authenticationSessionToken: String,
    @field:Schema(description = "The A parameter hex encoded")
    val publicA: String,
    @field:Schema(description = "The M1 parameter hex encoded")
    val publicM1: String,
    // Session Data
    @field:Schema(example = EXAMPLE_SESSION_NAME)
    val sessionName: String? = null,
)
