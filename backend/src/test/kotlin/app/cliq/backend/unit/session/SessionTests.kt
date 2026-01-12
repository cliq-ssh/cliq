package app.cliq.backend.unit.session

import app.cliq.backend.session.Session
import app.cliq.backend.user.User
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.mockito.Mockito.mock
import java.time.OffsetDateTime
import java.time.ZoneOffset

class SessionTests {
    private val user: User = mock(User::class.java)

    @Test
    fun `isExpired returns false when now is before expiresAt`() {
        val expiresAt = OffsetDateTime.of(2025, 1, 1, 0, 0, 0, 0, ZoneOffset.UTC)
        val now = expiresAt.minusSeconds(1)
        val session = createSessionWithExpiresAt(expiresAt)

        assertFalse(session.isExpired(now))
    }

    @Test
    fun `isExpired returns false when now equals expiresAt`() {
        val expiresAt = OffsetDateTime.of(2025, 1, 1, 0, 0, 0, 0, ZoneOffset.UTC)
        val session = createSessionWithExpiresAt(expiresAt)

        assertFalse(session.isExpired(expiresAt))
    }

    @Test
    fun `isExpired returns true when now is after expiresAt`() {
        val expiresAt = OffsetDateTime.of(2025, 1, 1, 0, 0, 0, 0, ZoneOffset.UTC)
        val now = expiresAt.plusSeconds(1)
        val session = createSessionWithExpiresAt(expiresAt)

        assertTrue(session.isExpired(now))
    }

    private fun createSessionWithExpiresAt(expiresAt: OffsetDateTime): Session =
        Session(
            id = null,
            oidcSessionId = null,
            user = user,
            refreshToken = "refresh-token",
            name = null,
            lastUsedAt = null,
            expiresAt = expiresAt,
            createdAt = OffsetDateTime.now(),
        )
}
