package app.cliq.backend.error

import io.swagger.v3.oas.annotations.media.Schema

@ConsistentCopyVisibility
@Schema
data class ErrorCode private constructor(
    @field:Schema(example = "1", description = "The error code, which is a unique identifier for the error")
    val code: UShort,
    @field:Schema(example = "Example Error description", description = "The error code description for the error")
    val description: String,
) {
    companion object {
        // ### Internal Server errors ###
        val UNKNOWN_ERROR = of(1000U, "Unknown error")

        // ### User errors ###
        val VALIDATION_ERROR = of(2000U, "Validation error")
        val USER_WITH_EMAIL_NOT_FOUND = of(2001U, "User with email not found")
        val EMAIL_NOT_VERIFIED = of(2002U, "Email not verified")
        val EMAIL_NOT_FOUND_OR_VALID = of(2003U, "Email not found or valid")
        val PASSWORD_RESET_TOKEN_NOT_FOUND = of(2004U, "Password reset token not found")
        val PASSWORD_RESET_TOKEN_EXPIRED = of(2005U, "Password reset token is expired")
        val INVALID_VERIFY_PARAMS = of(2006U, "Invalid email or verification token")
        val EMAIL_VERIFICATION_TOKEN_EXPIRED = of(2007U, "Email verification token is expired")
        val EMAIL_ALREADY_VERIFIED = of(2008U, "Email is already verified")
        val INVALID_RESET_PARAMS = of(2009U, "Invalid email or reset token")

        // Authentication errors
        val AUTH_TOKEN_MISSING = of(2100U, "Authentication token is missing")
        val INVALID_AUTH_TOKEN = of(2101U, "Invalid authentication token")

        private fun of(
            code: UShort,
            description: String,
        ): ErrorCode = ErrorCode(code, description)
    }
}
