package app.cliq.backend.auth.factory

import app.cliq.backend.auth.oidc.OidcCallbackToken
import app.cliq.backend.auth.oidc.OidcCallbackTokenRepository
import app.cliq.backend.user.User
import app.cliq.backend.utils.TokenGenerator
import jakarta.servlet.http.HttpServletRequest
import org.springframework.stereotype.Service
import java.time.Clock
import java.time.OffsetDateTime

@Service
class OidcCallbackTokenFactory(
    private val authExchangeFactory: AuthExchangeFactory,
    private val oidcCallbackTokenRepository: OidcCallbackTokenRepository,
    private val tokenGenerator: TokenGenerator,
    private val clock: Clock,
) {
    fun createFromRequestAndUser(
        httpServletRequest: HttpServletRequest,
        user: User,
        oidcSessionId: String?,
    ): OidcCallbackToken = create(httpServletRequest.remoteAddr, user, oidcSessionId)

    fun create(ipAddress: String, user: User, oidcSessionId: String?): OidcCallbackToken {
        val exchangeCode = authExchangeFactory.create(ipAddress, user)
        val token = tokenGenerator.generateOidcCallbackToken()
        val now = OffsetDateTime.now(clock)

        val oidcCallbackToken =
            OidcCallbackToken(
                exchangeCode,
                oidcSessionId,
                token,
                now,
            )

        return oidcCallbackTokenRepository.save(oidcCallbackToken)
    }
}
