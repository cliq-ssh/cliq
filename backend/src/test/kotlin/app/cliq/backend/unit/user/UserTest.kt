package app.cliq.backend.unit.user

import app.cliq.backend.api.user.PASSWORD_RESET_TOKEN_INTERVAL_MINUTES
import app.cliq.backend.api.user.UNVERIFIED_USER_INTERVAL_MINUTES
import app.cliq.backend.api.user.User
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.time.OffsetDateTime

class UserTest {
    private fun createTestUser(
        emailVerificationToken: String? = null,
        emailVerificationSentAt: OffsetDateTime? = null,
        resetToken: String? = null,
        resetSentAt: OffsetDateTime? = null,
    ): User =
        User(
            id = 1L,
            email = "test@example.com",
            name = "Test User",
            password = "password",
            emailVerificationToken = emailVerificationToken,
            emailVerificationSentAt = emailVerificationSentAt,
            resetToken = resetToken,
            resetSentAt = resetSentAt,
            createdAt = OffsetDateTime.now(),
            updatedAt = OffsetDateTime.now(),
        )

    @Test
    fun `isEmailVerificationTokenValid should return true when token is not null and not expired`() {
        // Given
        val user =
            createTestUser(
                emailVerificationToken = "valid_token",
                emailVerificationSentAt = OffsetDateTime.now(),
            )

        assertThat(user.isEmailVerificationTokenValid()).isTrue()
    }

    @Test
    fun `isEmailVerificationTokenValid should return false when token is null`() {
        // Given
        val user =
            createTestUser(
                emailVerificationToken = null,
                emailVerificationSentAt = OffsetDateTime.now(),
            )

        assertThat(user.isEmailVerificationTokenValid()).isFalse()
    }

    @Test
    fun `isEmailVerificationTokenValid should return false when sent date is null`() {
        // Given
        val user =
            createTestUser(
                emailVerificationToken = "valid_token",
                emailVerificationSentAt = null,
            )

        assertThat(user.isEmailVerificationTokenValid()).isFalse()
    }

    @Test
    fun `isEmailVerificationTokenValid should return false when both token and sent date are null`() {
        // Given
        val user =
            createTestUser(
                emailVerificationToken = null,
                emailVerificationSentAt = null,
            )

        assertThat(user.isEmailVerificationTokenValid()).isFalse()
    }

    @Test
    fun `isEmailVerificationTokenValid should return false when sent date was created before the specified time`() {
        // Given
        val pastTime = OffsetDateTime.now().minusMinutes(UNVERIFIED_USER_INTERVAL_MINUTES + 1)
        val user =
            createTestUser(
                emailVerificationToken = "valid_token",
                emailVerificationSentAt = pastTime,
            )

        assertThat(user.isEmailVerificationTokenValid()).isFalse()
    }

    @Test
    fun `isEmailVerificationTokenExpired should return false when sent date is within valid interval`() {
        // Given
        val user =
            createTestUser(
                emailVerificationToken = "valid_token",
                emailVerificationSentAt = OffsetDateTime.now().minusMinutes(30),
            )

        assertThat(user.isEmailVerificationTokenExpired()).isFalse()
    }

    @Test
    fun `isEmailVerificationTokenExpired should return true when sent date is null`() {
        // Given
        val user =
            createTestUser(
                emailVerificationToken = "valid_token",
                emailVerificationSentAt = null,
            )

        assertThat(user.isEmailVerificationTokenExpired()).isTrue()
    }

    @Test
    fun `isEmailVerificationTokenExpired should return true when sent date is beyond valid interval`() {
        // Given
        val expiredTime = OffsetDateTime.now().minusMinutes(UNVERIFIED_USER_INTERVAL_MINUTES + 1)
        val user =
            createTestUser(
                emailVerificationToken = "valid_token",
                emailVerificationSentAt = expiredTime,
            )

        assertThat(user.isEmailVerificationTokenExpired()).isTrue()
    }

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
