package app.cliq.backend.config.security.oidc

import app.cliq.backend.session.SessionRepository
import app.cliq.backend.user.UserRepository
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.slf4j.LoggerFactory
import org.springframework.security.core.Authentication
import org.springframework.security.oauth2.client.oidc.authentication.logout.OidcLogoutToken
import org.springframework.security.web.authentication.logout.LogoutHandler
import org.springframework.stereotype.Component

@Component
class OidcLogoutHandler(
    private val sessionRepository: SessionRepository,
    private val userRepository: UserRepository,
) : LogoutHandler {
    private val logger = LoggerFactory.getLogger(this::class.java)

    override fun logout(
        request: HttpServletRequest,
        response: HttpServletResponse,
        authentication: Authentication?,
    ) {
        if (authentication == null) {
            logger.error("No authentication found for logout request")
            return
        }

        val token = authentication.principal as OidcLogoutToken
        val deletedSessions = when (val sessionId = token.sessionId) {
            null -> {
                deleteWithOidcUser(token.subject)
            }

            else -> {
                deleteWithOidcSessionId(sessionId)
            }
        }

        logger.debug("Deleted $deletedSessions sessions during logout")
    }

    private fun deleteWithOidcSessionId(sessionId: String): Int {
        logger.debug("Delete session with OIDC session ID: $sessionId")
        return sessionRepository.deleteByOidcSessionId(sessionId)
    }

    private fun deleteWithOidcUser(sub: String): Int {
        val user = userRepository.findByOidcSub(sub)
        if (user == null) {
            logger.debug("No user found with OIDC subject: $sub")
            return 0
        }

        logger.debug("Delete all sessions for user ID: ${user.id}")
        return sessionRepository.deleteAllByUserId(user.id!!)
    }
}
