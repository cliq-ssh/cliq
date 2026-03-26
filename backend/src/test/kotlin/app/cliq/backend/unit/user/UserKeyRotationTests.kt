package app.cliq.backend.unit.user

import app.cliq.backend.user.KEY_ROTATION_TOKEN_INTERVAL_MINUTES
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.time.OffsetDateTime

class UserKeyRotationTests : AbstractUserTests() {
    @Test
    fun `isKeyRotationTokenExpired should return false when both token and sent date are null`() {
        // Given
        val user =
            createTestUser(
                keyRotationToken = null,
                keyRotationSentAt = null,
            )

        assertThat(user.isKeyRotationTokenExpired()).isFalse()
    }

    @Test
    fun `isKeyRotationTokenExpired should return false when token is null but sent date exists`() {
        // Given
        val user =
            createTestUser(
                keyRotationToken = null,
                keyRotationSentAt = OffsetDateTime.now().minusMinutes(10),
            )

        assertThat(user.isKeyRotationTokenExpired()).isFalse()
    }

    @Test
    fun `isKeyRotationTokenExpired should return false when token exists but sent date is null`() {
        // Given
        val user =
            createTestUser(
                keyRotationToken = "valid_reset_token",
                keyRotationSentAt = null,
            )

        assertThat(user.isKeyRotationTokenExpired()).isFalse()
    }

    @Test
    fun `isKeyRotationTokenExpired should return true when token is valid and within time limit`() {
        // Given
        val user =
            createTestUser(
                keyRotationToken = "valid_reset_token",
                keyRotationSentAt = OffsetDateTime.now().minusMinutes(15),
            )

        assertThat(user.isKeyRotationTokenExpired()).isTrue()
    }

    @Test
    fun `isKeyRotationTokenExpired should return false when token is expired beyond time limit`() {
        // Given
        val expiredTime = OffsetDateTime.now().minusMinutes(KEY_ROTATION_TOKEN_INTERVAL_MINUTES + 1)
        val user =
            createTestUser(
                keyRotationToken = "expired_reset_token",
                keyRotationSentAt = expiredTime,
            )

        assertThat(user.isKeyRotationTokenExpired()).isFalse()
    }
}
