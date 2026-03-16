package app.cliq.backend.auth.service

import app.cliq.backend.auth.AuthExchange
import app.cliq.backend.auth.AuthExchangeRepository
import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.exception.InvalidAuthExchangeCodeException
import app.cliq.backend.exception.InvalidIPAddressException
import jakarta.servlet.http.HttpServletRequest
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class AuthExchangeService(
    private val authExchangeRepository: AuthExchangeRepository,
    private val clock: Clock,
    private val jwtService: JwtService,
) {
    fun getValidAuthExchangeByCode(code: String, request: HttpServletRequest): AuthExchange {
        val authExchange =
            authExchangeRepository.findByExchangeCode(code)
                ?: throw InvalidAuthExchangeCodeException()

        validOrThrowAuthExchange(authExchange, request)

        return authExchange
    }

    fun validOrThrowAuthExchange(authExchange: AuthExchange, request: HttpServletRequest) {
        val now = OffsetDateTime.now(clock)
        if (authExchange.isExpired(now)) throw InvalidAuthExchangeCodeException()

        val expectedIpAddress = authExchange.ipAddress.hostAddress
        if (expectedIpAddress != request.remoteAddr) {
            throw InvalidIPAddressException()
        }
    }

    fun exchange(authExchange: AuthExchange, sessionName: String?): TokenPair =
        jwtService.generateTokenPairFromAuthExchange(authExchange, sessionName)
}
