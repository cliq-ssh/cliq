package app.cliq.backend.api.session

import app.cliq.backend.api.user.User
import app.cliq.backend.service.SnowflakeGenerator
import app.cliq.backend.service.TokenGenerator
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class SessionFactory(
    private val sessionRepository: SessionRepository,
    private val snowflakeGenerator: SnowflakeGenerator,
    private val tokenGenerator: TokenGenerator,
    private val clock: Clock,
) {
    fun createFromCreationParams(
        params: SessionCreationParams,
        user: User,
    ): Session {
        val session = createSession(user, params.name, params.userAgent)

        sessionRepository.saveAndFlush(session)

        return session
    }

    private fun createSession(
        user: User,
        name: String? = null,
        userAgent: String? = null,
    ): Session =
        Session(
            snowflakeGenerator.nextId().getOrThrow(),
            user,
            tokenGenerator.generateAuthVerificationToken(),
            name,
            userAgent,
            OffsetDateTime.now(clock),
            OffsetDateTime.now(clock),
            OffsetDateTime.now(clock),
        )
}
