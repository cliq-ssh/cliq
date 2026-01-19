package app.cliq.backend.config.security.jwt

import app.cliq.backend.config.security.jwt.service.JwtAuthenticationFactory
import jakarta.servlet.http.HttpServletRequest
import org.springframework.http.HttpHeaders
import org.springframework.security.core.Authentication
import org.springframework.security.web.authentication.AuthenticationConverter

const val BEARER_PREFIX = "Bearer "

class JwtAuthenticationConverter(
    private val jwtAuthenticationFactory: JwtAuthenticationFactory,
) : AuthenticationConverter {
    override fun convert(request: HttpServletRequest): Authentication? {
        val authHeaderValue = request.getHeader(HttpHeaders.AUTHORIZATION) ?: return null
        val jwtAccessToken = authHeaderValue.removePrefix(BEARER_PREFIX).trim()
        if (jwtAccessToken.isBlank() || jwtAccessToken == authHeaderValue) {
            return null
        }

        return jwtAuthenticationFactory.createUnauthenticated(jwtAccessToken)
    }
}
