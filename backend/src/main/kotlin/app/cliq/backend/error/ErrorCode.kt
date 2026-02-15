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
        val PASSWORD_RESET_TOKEN_EXPIRED = of(2005U, "Password reset token is expired")
        val INVALID_VERIFY_PARAMS = of(2006U, "Invalid email or verification token")
        val EMAIL_VERIFICATION_TOKEN_NOT_FOUND = of(2007U, "Email verification token not found")
        val EMAIL_VERIFICATION_TOKEN_EXPIRED = of(2008U, "Email verification token is expired")
        val EMAIL_ALREADY_VERIFIED = of(2009U, "Email is already verified")
        val INVALID_RESET_PARAMS = of(2010U, "Invalid email or reset token")

        // ### Authentication errors ###
        val MISSING_AUTHENTICATION_TOKEN = of(2100U, "Missing authentication token")
        val INVALID_JWT_ACCESS_TOKEN = of(2101U, "Invalid authentication token")
        val INVALID_REFRESH_TOKEN = of(2102U, "Invalid refresh token")
        val REFRESH_TOKEN_EXPIRED = of(2103U, "Refresh token is expired")
        val INVALID_CREDENTIALS = of(2104U, "Invalid credentials")

        // Rate limiting
        val RATE_LIMIT_EXCEEDED = of(2200U, "Rate limit exceeded")

        // ### Limitation errors ###
        val LOCAL_LOGIN_DISABLED = of(3000U, "Local login is disabled")
        val LOCAL_REGISTRATION_DISABLED = of(3001U, "Local registration is disabled")

        private fun of(
            code: UShort,
            description: String,
        ): ErrorCode = ErrorCode(code, description)
    }
}
