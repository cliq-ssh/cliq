package sh.cliq.backend.session

import org.springframework.stereotype.Service
import sh.cliq.backend.auth.jwt.RefreshToken
import sh.cliq.backend.user.User
import java.time.Clock
import java.time.OffsetDateTime

@Service
class SessionFactory(private val sessionRepository: SessionRepository, private val clock: Clock) {
    fun createWithSessionName(sessionName: String?, user: User, refreshToken: RefreshToken): Session = createSession(
        user = user,
        refreshToken = refreshToken,
        name = sessionName,
    )

    fun createFromOidcUser(user: User, oidcSessionId: String?, refreshToken: RefreshToken): Session =
        createSession(user, refreshToken, oidcSessionId = oidcSessionId)

    private fun createSession(
        user: User,
        refreshToken: RefreshToken,
        name: String? = null,
        oidcSessionId: String? = null,
    ): Session {
        val session =
            Session(
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
