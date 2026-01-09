package app.cliq.backend.config.security.jwt

import app.cliq.backend.auth.service.JwtResolver
import app.cliq.backend.config.security.jwt.service.JwtAuthenticationFactory
import app.cliq.backend.exception.AuthenticationMissingException
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.session.event.SessionUsedEvent
import jakarta.transaction.Transactional
import org.springframework.context.ApplicationEventPublisher
import org.springframework.security.authentication.AuthenticationProvider
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Component

@Component
class JwtAuthenticationProvider(
    private val sessionRepository: SessionRepository,
    private val eventPublisher: ApplicationEventPublisher,
    private val jwtAuthenticationFactory: JwtAuthenticationFactory,
    private val jwtResolver: JwtResolver,
) : AuthenticationProvider {
    @Transactional
    override fun authenticate(authentication: Authentication): Authentication {
        val jwtAuthentication = authentication as JwtAuthentication

        val jwtAccessToken = jwtAuthentication.credentials
            ?: throw AuthenticationMissingException()

        val session = jwtResolver.resolveSessionFromJwt(jwtAccessToken)
        eventPublisher.publishEvent(SessionUsedEvent(session.id!!))

        return jwtAuthenticationFactory.createAuthenticated(session)
    }

    override fun supports(authentication: Class<*>): Boolean = authentication == JwtAuthentication::class.java
}
