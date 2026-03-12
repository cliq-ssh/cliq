package app.cliq.backend.config.security.oidc

import app.cliq.backend.auth.factory.AuthExchangeFactory
import app.cliq.backend.auth.jwt.JwtClaims
import app.cliq.backend.user.service.UserOidcService
import app.cliq.backend.utils.CliqUrlUtils
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.security.core.Authentication
import org.springframework.security.oauth2.core.oidc.user.OidcUser
import org.springframework.security.web.authentication.AuthenticationSuccessHandler
import org.springframework.stereotype.Component

@Component
class OidcLoginSuccessHandler(
    private val userOidcService: UserOidcService,
    private val authExchangeFactory: AuthExchangeFactory,
    private val cliqUrlUtils: CliqUrlUtils,
) : AuthenticationSuccessHandler {
    override fun onAuthenticationSuccess(
        request: HttpServletRequest,
        response: HttpServletResponse,
        authentication: Authentication,
    ) {
        val oidcUser = authentication.principal as OidcUser
        val user = userOidcService.putUserFromOidcUser(oidcUser)
        val oidcSessionId = extractSessionId(oidcUser)
        val authExchange = authExchangeFactory.createFromRequestAndUser(request, user, oidcSessionId)
        val uri = cliqUrlUtils.buildOidcAppRedirectUrl(authExchange.exchangeCode)

        response.sendRedirect(uri.toString())
    }

    private fun extractSessionId(oidcUser: OidcUser): String? = oidcUser.idToken.getClaim(JwtClaims.SID) as String?
}
