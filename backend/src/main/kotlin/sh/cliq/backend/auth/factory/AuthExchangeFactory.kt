package sh.cliq.backend.auth.factory

import org.springframework.stereotype.Service
import sh.cliq.backend.auth.AuthExchange
import sh.cliq.backend.auth.AuthExchangeRepository
import sh.cliq.backend.config.properties.AuthProperties
import sh.cliq.backend.user.User
import sh.cliq.backend.utils.TokenGenerator
import java.time.Clock
import java.time.OffsetDateTime

@Service
class AuthExchangeFactory(
    private val authExchangeRepository: AuthExchangeRepository,
    private val tokenGenerator: TokenGenerator,
    private val clock: Clock,
    private val authProperties: AuthProperties,
) {
    fun createFromRequestAndUser(user: User): AuthExchange = create(user)

    fun create(user: User): AuthExchange {
        val token = tokenGenerator.generateAuthExchangeCode()
        val now = OffsetDateTime.now(clock)
        val expiresAt = now.plusSeconds(authProperties.authExchangeDurationSeconds)

        val exchange =
            AuthExchange(
                user = user,
                oidcCallbackToken = null,
                exchangeCode = token,
                createdAt = now,
                expiresAt = expiresAt,
            )

        return authExchangeRepository.save(exchange)
    }
}
