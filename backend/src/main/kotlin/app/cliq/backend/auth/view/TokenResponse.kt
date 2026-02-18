package app.cliq.backend.auth.view

import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.session.Session
import app.cliq.backend.session.view.SessionResponse
import io.swagger.v3.oas.annotations.media.Schema
import java.time.OffsetDateTime

@Schema
class TokenResponse(
    @field:Schema(description = "JWT Access token")
    val accessToken: String,
    @field:Schema(description = "JWT Refresh token")
    val refreshToken: String,
    id: Long,
    name: String? = null,
    lastUsedAt: OffsetDateTime? = null,
    expiresAt: OffsetDateTime,
    createdAt: OffsetDateTime,
) : SessionResponse(id, name, lastUsedAt, expiresAt, createdAt) {
    companion object {
        fun fromTokenPair(tokenPair: TokenPair): TokenResponse =
            fromTokensAndSession(tokenPair.jwt.tokenValue, tokenPair.refreshToken, tokenPair.session)

        fun fromTokensAndSession(
            accessToken: String,
            refreshToken: String,
            session: Session,
        ): TokenResponse =
            TokenResponse(
                accessToken = accessToken,
                refreshToken = refreshToken,
                id = session.id!!,
                name = session.name,
                lastUsedAt = session.lastUsedAt,
                expiresAt = session.expiresAt,
                createdAt = session.createdAt,
            )
    }
}
