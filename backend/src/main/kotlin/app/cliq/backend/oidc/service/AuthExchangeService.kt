package app.cliq.backend.oidc.service

import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.exception.InvalidIPAddressException
import app.cliq.backend.exception.InvalidOidcAuthExchangeCodeException
import app.cliq.backend.oidc.AuthExchange
import app.cliq.backend.oidc.AuthExchangeRepository
import jakarta.servlet.http.HttpServletRequest
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class AuthExchangeService(
    private val authExchangeRepository: AuthExchangeRepository,
    private val clock: Clock,
) {
    fun getValidAuthExchangeByCode(
        code: String,
        request: HttpServletRequest,
    ): AuthExchange {
        val authExchange =
            authExchangeRepository.findByExchangeCode(code)
                ?: throw InvalidOidcAuthExchangeCodeException()

        val now = OffsetDateTime.now(clock)
        if (authExchange.isExpired(now)) throw InvalidOidcAuthExchangeCodeException()

        val expectedIpAddress = authExchange.ipAddress.hostAddress
        if (expectedIpAddress != request.remoteAddr) {
            throw InvalidIPAddressException()
        }

        return authExchange
    }

    fun consumeToTokenResponse(authExchange: AuthExchange): TokenResponse {
        val response =
            TokenResponse.fromTokensAndSession(
                authExchange.jwtToken,
                authExchange.refreshToken,
                authExchange.session,
            )
        authExchangeRepository.delete(authExchange)

        return response
    }
}
