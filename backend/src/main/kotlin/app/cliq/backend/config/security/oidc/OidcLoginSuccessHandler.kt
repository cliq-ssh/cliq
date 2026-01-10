package app.cliq.backend.config.security.oidc

import app.cliq.backend.session.Session
import app.cliq.backend.session.SessionFactory
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

        TODO("Generate a proper todo value to send to the client")
//        response.sendRedirect("cliq://oauth/callback?apiKey=${todo}")
    }

    private fun getSessionForOidcUser(
        user: User,
        oidcUser: OidcUser,
    ): Session {
        val oidcSessionId = extractSessionId(oidcUser)
        val existingSession =
            oidcSessionId?.let {
                sessionRepository.findByOidcSessionId(it)
            }
        if (existingSession != null) {
            return existingSession
        }

        TODO("Update to new JWT workflow")
//        return sessionFactory.createFromOidcUser(user, oidcSessionId)
    }

    private fun extractSessionId(oidcUser: OidcUser): String? = oidcUser.idToken.getClaim("sid") as String?
}
