package app.cliq.backend.config.security.jwt

import app.cliq.backend.config.security.jwt.service.JwtAuthenticationFactory
import app.cliq.backend.config.security.jwt.service.JwtAuthenticationFilter
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer
import org.springframework.security.web.AuthenticationEntryPoint
import org.springframework.stereotype.Component

/**
 * Configurer to set up API key authentication in the Spring Security filter chain.
 * The order the request follows is:
 * Filter -> Converter -> Authentication -> Provider ->
 */
@Component
class JwtAuthenticationConfigurer(
    private val authenticationProvider: JwtAuthenticationProvider,
    private val authenticationEntryPoint: AuthenticationEntryPoint,
    jwtAuthenticationFactory: JwtAuthenticationFactory,
) : AbstractHttpConfigurer<JwtAuthenticationConfigurer, HttpSecurity>() {
    private val jwtAuthenticationConverter = JwtAuthenticationConverter(jwtAuthenticationFactory)

    override fun init(builder: HttpSecurity) {
        super.init(builder)
        builder.authenticationProvider(authenticationProvider)
    }

    override fun configure(builder: HttpSecurity) {
        val authenticationManager: AuthenticationManager =
            builder.getSharedObject<AuthenticationManager>(AuthenticationManager::class.java)

        builder.addFilter(
            JwtAuthenticationFilter(
                authenticationManager,
                jwtAuthenticationConverter,
                authenticationEntryPoint,
            ),
        )
    }
}
