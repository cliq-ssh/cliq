package app.cliq.backend.auth.factory

import app.cliq.backend.auth.AuthExchange
import app.cliq.backend.auth.AuthExchangeRepository
import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.config.properties.AuthProperties
import app.cliq.backend.session.Session
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
    fun createFromRequestAndSession(
        httpServletRequest: HttpServletRequest,
        tokenPair: TokenPair,
    ): AuthExchange =
        create(httpServletRequest.remoteAddr, tokenPair.session, tokenPair.jwt.tokenValue, tokenPair.refreshToken)

    fun create(
        ipAddress: String,
        session: Session,
        jwtToken: String,
        refreshToken: String,
    ): AuthExchange {
        val token = tokenGenerator.generateAuthExchangeCode()
        val inetAddress = InetAddress.ofLiteral(ipAddress)
        val now = OffsetDateTime.now(clock)
        val expiresAt = now.plusSeconds(authProperties.authExchangeDurationSeconds)

        val exchange =
            AuthExchange(
                session = session,
                exchangeCode = token,
                ipAddress = inetAddress,
                jwtToken = jwtToken,
                refreshToken = refreshToken,
                createdAt = now,
                expiresAt = expiresAt,
            )

        return authExchangeRepository.save(exchange)
    }
}
