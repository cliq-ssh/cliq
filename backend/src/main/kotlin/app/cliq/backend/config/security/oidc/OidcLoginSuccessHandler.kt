package app.cliq.backend.config.security.oidc

import app.cliq.backend.auth.jwt.JwtClaims
import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.auth.service.JwtService
import app.cliq.backend.auth.service.RefreshTokenService
import app.cliq.backend.oidc.factory.AuthExchangeFactory
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.user.User
import app.cliq.backend.user.service.UserOidcService
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.security.core.Authentication
import org.springframework.security.oauth2.core.oidc.user.OidcUser
import org.springframework.security.web.authentication.AuthenticationSuccessHandler
import org.springframework.stereotype.Component

@Component
class OidcLoginSuccessHandler(
    private val userOidcService: UserOidcService,
    private val jwtService: JwtService,
    private val refreshTokenService: RefreshTokenService,
    private val sessionRepository: SessionRepository,
    private val authExchangeFactory: AuthExchangeFactory,
) : AuthenticationSuccessHandler {
    override fun onAuthenticationSuccess(
        request: HttpServletRequest,
        response: HttpServletResponse,
        authentication: Authentication,
    ) {
        val oidcUSer = authentication.principal as OidcUser
        val user = userOidcService.putUserFromJwt(oidcUSer)
        val tokenPair = getTokenPairFromOidcUser(user, oidcUSer)
        val authExchange = authExchangeFactory.createFromRequestAndSession(request, tokenPair)

        response.sendRedirect(
            "cliq://oauth/callback?exchangeCode=${authExchange.exchangeCode}",
        )
    }

    private fun getTokenPairFromOidcUser(
        user: User,
        oidcUser: OidcUser,
    ): TokenPair {
        val oidcSessionId = extractSessionId(oidcUser)
        val existingSession =
            oidcSessionId?.let {
                sessionRepository.findByOidcSessionId(it)
            }
        if (existingSession == null) {
            return jwtService.generateOidcJwtTokenPair(user, oidcSessionId)
        }

        return refreshTokenService.rotate(existingSession)
    }

    private fun extractSessionId(oidcUser: OidcUser): String? = oidcUser.idToken.getClaim(JwtClaims.SID) as String?
}
