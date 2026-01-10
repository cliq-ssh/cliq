package app.cliq.backend.config.security.jwt.service

import app.cliq.backend.config.security.jwt.JwtAuthentication
import app.cliq.backend.session.Session
import org.springframework.stereotype.Service

@Service
class JwtAuthenticationFactory {
    fun createAuthenticated(session: Session): JwtAuthentication =
        create(
            session = session,
            authenticated = true,
            jwtAccessToken = null,
        )

    fun createUnauthenticated(jwtAccessToken: String): JwtAuthentication =
        create(
            session = null,
            authenticated = false,
            jwtAccessToken = jwtAccessToken,
        )

    private fun create(
        session: Session?,
        authenticated: Boolean,
        jwtAccessToken: String?,
    ): JwtAuthentication = JwtAuthentication(emptyList(), session, authenticated, jwtAccessToken)
}
