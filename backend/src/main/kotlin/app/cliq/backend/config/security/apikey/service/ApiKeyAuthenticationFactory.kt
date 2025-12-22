package app.cliq.backend.config.security.apikey.service

import app.cliq.backend.auth.AuthUser
import app.cliq.backend.config.security.apikey.ApiKeyAuthentication
import org.springframework.stereotype.Service

@Service
class ApiKeyAuthenticationFactory {
    fun createAuthenticated(authUser: AuthUser): ApiKeyAuthentication =
        create(
            authUser = authUser,
            authenticated = true,
            apiKey = null,
        )

    fun createUnauthenticated(apiKey: String): ApiKeyAuthentication =
        create(
            authUser = null,
            authenticated = false,
            apiKey = apiKey,
        )

    private fun create(
        authUser: AuthUser?,
        authenticated: Boolean,
        apiKey: String?,
    ): ApiKeyAuthentication = ApiKeyAuthentication(emptyList(), authUser, authenticated, apiKey)
}
