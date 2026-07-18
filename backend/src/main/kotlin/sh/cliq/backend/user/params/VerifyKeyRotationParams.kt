package sh.cliq.backend.user.params

import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.Valid
import jakarta.validation.constraints.Email
import jakarta.validation.constraints.NotBlank
import jakarta.validation.constraints.NotEmpty
import sh.cliq.backend.constants.EXAMPLE_EMAIL
import sh.cliq.backend.vault.params.VaultParams

@Schema
data class VerifyKeyRotationParams(
    @field:Schema(example = EXAMPLE_EMAIL) @field:Email @field:NotEmpty val email: String,
    @field:Schema(example = "ABCD1234") @field:NotBlank val code: String,
    @field:Schema(example = "base64-encoded-key") @field:NotBlank val dataEncryptionKey: String,
    @field:Schema(example = "base64-encoded-salt", required = false) val srpSalt: String? = null,
    @field:Schema(example = "base64-encoded-verifier", required = false) val srpVerifier: String? = null,
    @field:Valid val vault: VaultParams,
)
