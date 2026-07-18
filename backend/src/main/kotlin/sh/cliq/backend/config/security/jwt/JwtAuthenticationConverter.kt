package sh.cliq.backend.config.security.jwt

import jakarta.servlet.http.HttpServletRequest
import org.springframework.http.HttpHeaders
import org.springframework.security.core.Authentication
import org.springframework.security.web.authentication.AuthenticationConverter
import sh.cliq.backend.config.security.jwt.service.JwtAuthenticationFactory

const val BEARER_PREFIX = "Bearer "

class JwtAuthenticationConverter(private val jwtAuthenticationFactory: JwtAuthenticationFactory) :
    AuthenticationConverter {
    override fun convert(request: HttpServletRequest): Authentication? {
        val authHeaderValue = request.getHeader(HttpHeaders.AUTHORIZATION)

        val jwtAccessToken =
            authHeaderValue
                ?.takeIf { it.startsWith(BEARER_PREFIX) }
                ?.removePrefix(BEARER_PREFIX)
                ?.trim()
                ?.takeIf { it.isNotBlank() }

        return jwtAccessToken?.let(jwtAuthenticationFactory::createUnauthenticated)
    }
}
