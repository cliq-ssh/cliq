package app.cliq.backend.unit.user

import app.cliq.backend.user.PASSWORD_RESET_TOKEN_INTERVAL_MINUTES
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.time.OffsetDateTime

class UserPasswordResetTests : AbstractUserTests() {
    @Test
    fun `isPasswordResetTokenExpired should return false when both token and sent date are null`() {
        // Given
        val user =
            createTestUser(
                resetToken = null,
                resetSentAt = null,
            )

        assertThat(user.isPasswordResetTokenExpired()).isFalse()
    }

    @Test
    fun `isPasswordResetTokenExpired should return false when token is null but sent date exists`() {
        // Given
        val user =
            createTestUser(
                resetToken = null,
                resetSentAt = OffsetDateTime.now().minusMinutes(10),
            )

        assertThat(user.isPasswordResetTokenExpired()).isFalse()
    }

    @Test
    fun `isPasswordResetTokenExpired should return false when token exists but sent date is null`() {
        // Given
        val user =
            createTestUser(
                resetToken = "valid_reset_token",
                resetSentAt = null,
            )

        assertThat(user.isPasswordResetTokenExpired()).isFalse()
    }

    @Test
    fun `isPasswordResetTokenExpired should return true when token is valid and within time limit`() {
        // Given
        val user =
            createTestUser(
                resetToken = "valid_reset_token",
                resetSentAt = OffsetDateTime.now().minusMinutes(15),
            )

        assertThat(user.isPasswordResetTokenExpired()).isTrue()
    }

    @Test
    fun `isPasswordResetTokenExpired should return false when token is expired beyond time limit`() {
        // Given
        val expiredTime = OffsetDateTime.now().minusMinutes(PASSWORD_RESET_TOKEN_INTERVAL_MINUTES + 1)
        val user =
            createTestUser(
                resetToken = "expired_reset_token",
                resetSentAt = expiredTime,
            )

        assertThat(user.isPasswordResetTokenExpired()).isFalse()
    }
}
