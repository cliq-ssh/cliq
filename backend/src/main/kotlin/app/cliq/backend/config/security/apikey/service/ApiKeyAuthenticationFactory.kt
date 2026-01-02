package app.cliq.backend.config.security.apikey.service

import app.cliq.backend.config.security.apikey.ApiKeyAuthentication
import app.cliq.backend.user.User
import org.springframework.stereotype.Service

@Service
class ApiKeyAuthenticationFactory {
    fun createAuthenticated(user: User): ApiKeyAuthentication =
        create(
            user = user,
            authenticated = true,
            apiKey = null,
        )

    fun createUnauthenticated(apiKey: String): ApiKeyAuthentication =
        create(
            user = null,
            authenticated = false,
            apiKey = apiKey,
        )

    private fun create(
        user: User?,
        authenticated: Boolean,
        apiKey: String?,
    ): ApiKeyAuthentication = ApiKeyAuthentication(emptyList(), user, authenticated, apiKey)
}
