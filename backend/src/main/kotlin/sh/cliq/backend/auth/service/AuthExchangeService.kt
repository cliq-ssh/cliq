package sh.cliq.backend.auth.service

import org.springframework.stereotype.Service
import sh.cliq.backend.auth.AuthExchange
import sh.cliq.backend.auth.AuthExchangeRepository
import sh.cliq.backend.auth.jwt.TokenPair
import sh.cliq.backend.exception.InvalidAuthExchangeCodeException
import java.time.Clock
import java.time.OffsetDateTime

@Service
class AuthExchangeService(
    private val authExchangeRepository: AuthExchangeRepository,
    private val clock: Clock,
    private val jwtService: JwtService,
) {
    fun getValidAuthExchangeByCode(code: String): AuthExchange {
        val authExchange =
            authExchangeRepository.findByExchangeCode(code)
                ?: throw InvalidAuthExchangeCodeException()

        validOrThrowAuthExchange(authExchange)

        return authExchange
    }

    fun validOrThrowAuthExchange(authExchange: AuthExchange) {
        val now = OffsetDateTime.now(clock)
        if (authExchange.isExpired(now)) throw InvalidAuthExchangeCodeException()
    }

    fun exchange(authExchange: AuthExchange, sessionName: String?): TokenPair =
        jwtService.generateTokenPairFromAuthExchange(authExchange, sessionName)
}
