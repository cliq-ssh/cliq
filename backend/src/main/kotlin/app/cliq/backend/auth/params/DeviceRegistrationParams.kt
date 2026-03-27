package app.cliq.backend.auth.params

import app.cliq.backend.constants.EXAMPLE_SESSION_NAME
import io.swagger.v3.oas.annotations.media.Schema
import jakarta.validation.constraints.NotBlank

@Schema
data class DeviceRegistrationParams(
    @field:NotBlank
    val exchangeCode: String,
    @field:Schema(description = "The device public key Base64 encoded")
    val devicePublicKey: String,
    @field:Schema(description = "The data encryption key encrypted with the device public key, Base64 encoded")
    val dataEncryptionKey: String,
    // Session Data
    @field:Schema(example = EXAMPLE_SESSION_NAME)
    val sessionName: String? = null,
)
