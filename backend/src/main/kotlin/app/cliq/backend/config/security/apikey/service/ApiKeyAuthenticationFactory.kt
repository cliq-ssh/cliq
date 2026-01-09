package app.cliq.backend.config.security.apikey.service

import app.cliq.backend.config.security.apikey.ApiKeyAuthentication
import app.cliq.backend.session.Session
import org.springframework.stereotype.Service

@Service
class ApiKeyAuthenticationFactory {
    fun createAuthenticated(session: Session): ApiKeyAuthentication =
        create(
            session = session,
            authenticated = true,
            apiKey = null,
        )

    fun createUnauthenticated(apiKey: String): ApiKeyAuthentication =
        create(
            session = null,
            authenticated = false,
            apiKey = apiKey,
        )

    private fun create(
        session: Session?,
        authenticated: Boolean,
        apiKey: String?,
    ): ApiKeyAuthentication = ApiKeyAuthentication(emptyList(), session, authenticated, apiKey)
}
