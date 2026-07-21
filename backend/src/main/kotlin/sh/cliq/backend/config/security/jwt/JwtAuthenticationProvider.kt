package sh.cliq.backend.config.security.jwt

import org.springframework.context.ApplicationEventPublisher
import org.springframework.security.authentication.AuthenticationProvider
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Component
import sh.cliq.backend.auth.service.JwtResolver
import sh.cliq.backend.config.security.jwt.service.JwtAuthenticationFactory
import sh.cliq.backend.session.event.SessionUsedEvent

@Component
class JwtAuthenticationProvider(
    private val eventPublisher: ApplicationEventPublisher,
    private val jwtAuthenticationFactory: JwtAuthenticationFactory,
    private val jwtResolver: JwtResolver,
) : AuthenticationProvider {
    override fun authenticate(authentication: Authentication): Authentication {
        val jwtAuthentication = authentication as JwtAuthentication

        val jwtAccessToken =
            jwtAuthentication.credentials
                ?: throw BadCredentialsException("Invalid JWT token")

        val session = jwtResolver.resolveSessionFromJwt(jwtAccessToken)
        eventPublisher.publishEvent(SessionUsedEvent(session.id!!))
        val authentication = jwtAuthenticationFactory.createAuthenticated(session)

        return authentication
    }

    override fun supports(authentication: Class<*>): Boolean = authentication == JwtAuthentication::class.java
}
