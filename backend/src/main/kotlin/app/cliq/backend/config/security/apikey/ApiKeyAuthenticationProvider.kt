package app.cliq.backend.config.security.apikey

import app.cliq.backend.auth.AuthUserFactory
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
    private val authUserFactory: AuthUserFactory,
    private val apiKeyAuthenticationFactory: ApiKeyAuthenticationFactory,
) : AuthenticationProvider {
    @Transactional
    override fun authenticate(authentication: Authentication): Authentication {
        val apiKeyAuthentication = authentication as ApiKeyAuthentication

        val apiKey = apiKeyAuthentication.credentials ?: throw BadCredentialsException("API key is missing")
        val session = sessionRepository.findByApiKey(apiKey) ?: throw BadCredentialsException("Invalid API key")
        val user = session.user
        val authUser =
            authUserFactory.createApiKeyUser(
                userId = user.id ?: throw IllegalStateException("User ID should not be null"),
                email = user.email,
                password = user.password,
            )
        eventPublisher.publishEvent(SessionUsedEvent(session.id!!))

        return apiKeyAuthenticationFactory.createAuthenticated(authUser)
    }

    override fun supports(authentication: Class<*>): Boolean = authentication == ApiKeyAuthentication::class.java
}
