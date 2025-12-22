package app.cliq.backend.config.security.apikey

import app.cliq.backend.config.security.apikey.service.ApiKeyAuthenticationFilter
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.security.web.access.intercept.AuthorizationFilter
import org.springframework.stereotype.Component

/**
 * Configurer to set up API key authentication in the Spring Security filter chain.
 * The order the request follows is:
 * Filter -> Converter -> Authentication -> Provider ->
 */
@Component
class ApiKeyAuthenticationConfigurer(
    private val authenticationProvider: ApiKeyAuthenticationProvider,
    private val apiKeyAuthenticationConverter: ApiKeyAuthenticationConverter,
    private val authenticationEntryPoint: AuthenticationEntryPoint,
) : AbstractHttpConfigurer<ApiKeyAuthenticationConfigurer, HttpSecurity>() {
    override fun init(builder: HttpSecurity) {
        super.init(builder)
        builder.authenticationProvider(authenticationProvider)
    }

    override fun configure(builder: HttpSecurity) {
        val authenticationManager: AuthenticationManager =
            builder.getSharedObject<AuthenticationManager>(AuthenticationManager::class.java)

        builder.addFilterBefore(
            ApiKeyAuthenticationFilter(
                authenticationManager,
                apiKeyAuthenticationConverter,
                authenticationEntryPoint,
            ),
            AuthorizationFilter::class.java,
        )
    }
}
