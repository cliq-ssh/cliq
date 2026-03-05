package app.cliq.backend.unit.oidc

import app.cliq.backend.auth.AuthExchange
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.junit.jupiter.MockitoExtension
import org.mockito.kotlin.mock
import java.net.InetAddress
import java.time.OffsetDateTime

@ExtendWith(MockitoExtension::class)
class AuthExchangeTests {
    private fun buildAuthExchange(
        expiresAt: OffsetDateTime,
        now: OffsetDateTime,
    ): AuthExchange =
        AuthExchange(
            session = mock(),
            exchangeCode = "exchange-code",
            ipAddress = InetAddress.getByName("127.0.0.1"),
            jwtToken = "jwt-token",
            refreshToken = "refresh-token",
            createdAt = now.minusMinutes(5),
            expiresAt = expiresAt,
        )

    @Test
    fun `isExpired returns false when now is before expiresAt`() {
        val now = OffsetDateTime.now()
        val exchange = buildAuthExchange(expiresAt = now.plusMinutes(5), now = now)

        assertFalse(exchange.isExpired(now))
    }

    @Test
    fun `isExpired returns true when now equals expiresAt`() {
        val now = OffsetDateTime.now()
        val exchange = buildAuthExchange(expiresAt = now, now = now)

        assertTrue(exchange.isExpired(now))
    }

    @Test
    fun `isExpired returns true when now is after expiresAt`() {
        val now = OffsetDateTime.now()
        val exchange = buildAuthExchange(expiresAt = now.minusSeconds(1), now = now)

        assertTrue(exchange.isExpired(now))
    }
}
