package app.cliq.backend.auth.jwt

import java.time.OffsetDateTime

data class RefreshToken(
    val tokenValue: String,
    val expiresAt: OffsetDateTime,
)
