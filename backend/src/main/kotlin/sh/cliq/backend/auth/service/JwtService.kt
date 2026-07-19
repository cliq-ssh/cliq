package sh.cliq.backend.auth.service

import org.springframework.stereotype.Service
import sh.cliq.backend.auth.AuthExchange
import sh.cliq.backend.auth.AuthExchangeRepository
import sh.cliq.backend.auth.factory.JwtFactory
import sh.cliq.backend.auth.jwt.TokenPair
import sh.cliq.backend.auth.oidc.OidcCallbackToken
import sh.cliq.backend.session.SessionRepository
import java.time.Clock
import java.time.OffsetDateTime

@Service
class JwtService(
    private val jwtFactory: JwtFactory,
    private val refreshTokenService: RefreshTokenService,
    private val sessionRepository: SessionRepository,
    private val authExchangeRepository: AuthExchangeRepository,
    private val clock: Clock,
) {
    fun generateTokenPairFromAuthExchange(authExchange: AuthExchange, sessionName: String?): TokenPair {
        if (authExchange.oidcCallbackToken != null) {
            return generateTokenPairForOidcUser(authExchange.oidcCallbackToken!!)
        }

        val now = OffsetDateTime.now(clock)
        val issuedRefreshToken = refreshTokenService.issue(sessionName, authExchange.user)

        val jwt = jwtFactory.generateJwtAccessToken(issuedRefreshToken.session, now)
        authExchangeRepository.delete(authExchange)

        return TokenPair(jwt, issuedRefreshToken.tokenValue, issuedRefreshToken.session)
    }

    private fun generateTokenPairForOidcUser(oidcCallbackToken: OidcCallbackToken): TokenPair {
        if (oidcCallbackToken.oidcSessionId != null) {
            val existingSession = sessionRepository.findByOidcSessionId(oidcCallbackToken.oidcSessionId!!)
            if (existingSession != null) {
                authExchangeRepository.delete(oidcCallbackToken.authExchange)

                return refreshTokenService.rotate(existingSession)
            }
        }

        val now = OffsetDateTime.now(clock)
        val issuedRefreshToken =
            refreshTokenService.issueForOidcUser(oidcCallbackToken.authExchange.user, oidcCallbackToken.oidcSessionId)

        val jwt = jwtFactory.generateJwtAccessToken(issuedRefreshToken.session, now)
        authExchangeRepository.delete(oidcCallbackToken.authExchange)

        return TokenPair(jwt, issuedRefreshToken.tokenValue, issuedRefreshToken.session)
    }
}
