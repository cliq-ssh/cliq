package app.cliq.backend.config.security.apikey.service

import app.cliq.backend.config.oidc.OidcProperties
import app.cliq.backend.config.security.apikey.BEARER_PREFIX
import app.cliq.backend.shared.API_KEY_PREFIX
import jakarta.servlet.http.HttpServletRequest
import org.springframework.http.HttpHeaders
import org.springframework.security.web.util.matcher.RequestMatcher
import org.springframework.stereotype.Component

@Component
class ApiKeyAuthenticationRequestMatcher(
    private val oidcProperties: OidcProperties,
) : RequestMatcher {
    override fun matches(request: HttpServletRequest): Boolean {
        if (!oidcProperties.enabled) {
            return true
        }

        val authHeaderValue = request.getHeader(HttpHeaders.AUTHORIZATION) ?: return false
        val apiKey = authHeaderValue.removePrefix(BEARER_PREFIX).trim()
        if (apiKey.isBlank() || apiKey == authHeaderValue) {
            return false
        }

        return apiKey.startsWith(API_KEY_PREFIX)
    }
}
