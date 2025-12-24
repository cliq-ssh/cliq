package app.cliq.backend.config.security.apikey

import app.cliq.backend.config.security.apikey.service.ApiKeyAuthenticationFactory
import jakarta.servlet.http.HttpServletRequest
import org.springframework.http.HttpHeaders
import org.springframework.security.core.Authentication
import org.springframework.security.web.authentication.AuthenticationConverter

const val BEARER_PREFIX = "Bearer "

class ApiKeyAuthenticationConverter(
    private val apiKeyAuthenticationFactory: ApiKeyAuthenticationFactory,
) : AuthenticationConverter {
    override fun convert(request: HttpServletRequest): Authentication? {
        val authHeaderValue = request.getHeader(HttpHeaders.AUTHORIZATION) ?: return null
        val apiKey = authHeaderValue.removePrefix(BEARER_PREFIX).trim()
        if (apiKey.isBlank() || apiKey == authHeaderValue) {
            return null
        }

        return apiKeyAuthenticationFactory.createUnauthenticated(apiKey)
    }
}
