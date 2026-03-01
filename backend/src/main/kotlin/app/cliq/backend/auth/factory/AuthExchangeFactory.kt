package app.cliq.backend.auth.factory

import app.cliq.backend.auth.AuthExchange
import app.cliq.backend.auth.AuthExchangeRepository
import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.config.properties.AuthProperties
import app.cliq.backend.session.Session
import app.cliq.backend.user.User
import app.cliq.backend.utils.TokenGenerator
import jakarta.servlet.http.HttpServletRequest
import org.springframework.stereotype.Service
import java.net.InetAddress
import java.time.Clock
import java.time.OffsetDateTime

@Service
class AuthExchangeFactory(
    private val authExchangeRepository: AuthExchangeRepository,
    private val tokenGenerator: TokenGenerator,
    private val clock: Clock,
    private val authProperties: AuthProperties,
) {
    fun createFromRequestAndUser(
        httpServletRequest: HttpServletRequest,
        user: User,
        oidcSessionId: String? = null,
    ): AuthExchange =
        create(httpServletRequest.remoteAddr, user, oidcSessionId)

    fun create(
        ipAddress: String,
        user: User,
        oidcSessionId: String? = null,
    ): AuthExchange {
        val token = tokenGenerator.generateAuthExchangeCode()
        val inetAddress = InetAddress.ofLiteral(ipAddress)
        val now = OffsetDateTime.now(clock)
        val expiresAt = now.plusSeconds(authProperties.authExchangeDurationSeconds)

        val exchange =
            AuthExchange(
                user = user,
                oidcSessionId = oidcSessionId,
                exchangeCode = token,
                ipAddress = inetAddress,
                createdAt = now,
                expiresAt = expiresAt,
            )

        return authExchangeRepository.save(exchange)
    }
}
