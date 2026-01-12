package app.cliq.backend.unit.user

import app.cliq.backend.user.UNVERIFIED_USER_INTERVAL_MINUTES
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.time.OffsetDateTime

class UserVerificationTests : AbstractUserTests() {
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
}
