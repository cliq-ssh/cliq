package app.cliq.backend.session

import app.cliq.backend.auth.jwt.RefreshToken
import app.cliq.backend.auth.params.LoginParams
import app.cliq.backend.user.User
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class SessionFactory(
    private val sessionRepository: SessionRepository,
    private val clock: Clock,
) {
    fun createFromLoginParams(
        loginParams: LoginParams,
        user: User,
        refreshToken: RefreshToken,
    ): Session {
        return createSession(user, refreshToken, loginParams.name)
    }

    fun createFromOidcUser(
        user: User,
        refreshToken: RefreshToken,
        oidcSessionId: String?,
    ): Session {
        return createSession(user, refreshToken, oidcSessionId = oidcSessionId)
    }

    private fun createSession(
        user: User,
        refreshToken: RefreshToken,
        name: String? = null,
        oidcSessionId: String? = null,
    ): Session {
        val session = Session(
            id = null,
            oidcSessionId = oidcSessionId,
            user = user,
            refreshToken = refreshToken.tokenValue,
            name = name,
            lastUsedAt = null,
            expiresAt = refreshToken.expiresAt,
            createdAt = OffsetDateTime.now(clock),
        )

        return sessionRepository.saveAndFlush(session)
    }
}
