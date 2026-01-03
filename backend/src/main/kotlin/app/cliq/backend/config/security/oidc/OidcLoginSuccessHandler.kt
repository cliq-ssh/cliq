package app.cliq.backend.config.security.oidc

import app.cliq.backend.session.Session
import app.cliq.backend.session.SessionFactory
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.user.User
import app.cliq.backend.user.UserOidcService
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.springframework.security.core.Authentication
import org.springframework.security.oauth2.core.oidc.user.OidcUser
import org.springframework.security.web.authentication.AuthenticationSuccessHandler
import org.springframework.stereotype.Component

@Component
class OidcLoginSuccessHandler(
    private val userOidcService: UserOidcService,
    private val sessionFactory: SessionFactory,
    private val sessionRepository: SessionRepository,
) : AuthenticationSuccessHandler {
    override fun onAuthenticationSuccess(
        request: HttpServletRequest,
        response: HttpServletResponse,
        authentication: Authentication,
    ) {
        val oidcUSer = authentication.principal as OidcUser
        val user = userOidcService.putUserFromJwt(oidcUSer)
        val session = getSessionForOidcUser(user, oidcUSer)

        response.sendRedirect("cliq://oauth/callback?apiKey=${session.apiKey}")
    }

    private fun getSessionForOidcUser(user: User, oidcUser: OidcUser): Session {
        val oidcSessionId = extractSessionId(oidcUser)
        val existingSession = oidcSessionId?.let {
            sessionRepository.findByOidcSessionId(it)
        }
        if (existingSession != null) {
            return existingSession
        }

        return sessionFactory.createFromOidcUser(user, oidcSessionId)
    }

    private fun extractSessionId(oidcUser: OidcUser): String? {
        return oidcUser.idToken.getClaim("sid") as String?
    }
}
