package app.cliq.backend.config.security.apikey

import app.cliq.backend.config.security.apikey.service.ApiKeyAuthenticationFactory
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.session.event.SessionUsedEvent
import jakarta.transaction.Transactional
import org.springframework.context.ApplicationEventPublisher
import org.springframework.security.authentication.AuthenticationProvider
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.core.Authentication
import org.springframework.stereotype.Component

@Component
class ApiKeyAuthenticationProvider(
    private val sessionRepository: SessionRepository,
    private val eventPublisher: ApplicationEventPublisher,
    private val apiKeyAuthenticationFactory: ApiKeyAuthenticationFactory,
) : AuthenticationProvider {
    @Transactional
    override fun authenticate(authentication: Authentication): Authentication {
        val apiKeyAuthentication = authentication as ApiKeyAuthentication

        val apiKey = apiKeyAuthentication.credentials ?: throw BadCredentialsException("API key is missing")
        TODO("Update to JWT Bearer token")
//        val session = sessionRepository.findByApiKey(apiKey) ?: throw BadCredentialsException("Invalid API key")
//        val user = session.user
//        eventPublisher.publishEvent(SessionUsedEvent(session.id!!))
//
//        return apiKeyAuthenticationFactory.createAuthenticated(user)
    }

    override fun supports(authentication: Class<*>): Boolean = authentication == ApiKeyAuthentication::class.java
}
