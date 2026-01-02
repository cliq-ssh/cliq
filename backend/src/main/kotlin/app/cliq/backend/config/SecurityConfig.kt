package app.cliq.backend.config

import app.cliq.backend.config.oidc.OidcProperties
import app.cliq.backend.config.security.apikey.ApiKeyAuthenticationConfigurer
import app.cliq.backend.config.security.oidc.OidcLoginSuccessHandler
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Lazy
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.web.SecurityFilterChain

const val SALT_LENGTH = 16
const val HASH_LENGTH = 32
const val PARALLELISM = 4
const val MEMORY = 1 shl 14
const val ITERATIONS = 3

@EnableMethodSecurity
@Configuration
class SecurityConfig(
    private val apiKeyAuthenticationConfigurer: ApiKeyAuthenticationConfigurer,
    private val oidcProperties: OidcProperties,
    @Lazy
    private val oidcLoginSuccessHandler: OidcLoginSuccessHandler,
) {
    @Bean
    fun passwordEncoder(): PasswordEncoder =
        Argon2PasswordEncoder(SALT_LENGTH, HASH_LENGTH, PARALLELISM, MEMORY, ITERATIONS)

    @Bean
    fun oidcFilterChain(http: HttpSecurity): SecurityFilterChain? {
        if (!oidcProperties.enabled) {
            return null
        }

        return http
            .securityMatcher("/oauth2/**", "/login/oauth2/**")
            .oauth2Login {
                it.successHandler(oidcLoginSuccessHandler)
            }.build()
    }

    // TODO:
    //  - access denied handler
    //  - fix 401 error handler
    @Bean
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .securityMatcher("/api/**")
            .csrf { it.disable() }
            .formLogin { it.disable() }
            .httpBasic { it.disable() }
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }
            .with(apiKeyAuthenticationConfigurer)

        return http.build()
    }
}
