package app.cliq.backend.config

import app.cliq.backend.config.security.exception.handler.ApplicationAuthenticationEntryPoint
import app.cliq.backend.config.security.jwt.JwtAuthenticationConfigurer
import app.cliq.backend.config.security.oidc.OidcLoginSuccessHandler
import app.cliq.backend.config.security.oidc.OidcLogoutHandler
import org.springframework.boot.autoconfigure.condition.ConditionalOnBooleanProperty
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
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

@Configuration
@EnableMethodSecurity
class SecurityConfig(
    private val jwtAuthenticationConfigurer: JwtAuthenticationConfigurer,
    private val applicationAuthenticationEntryPoint: ApplicationAuthenticationEntryPoint,
) {
    @Bean
    fun passwordEncoder(): PasswordEncoder =
        Argon2PasswordEncoder(SALT_LENGTH, HASH_LENGTH, PARALLELISM, MEMORY, ITERATIONS)

    @Bean
    @ConditionalOnBooleanProperty("app.oidc.enabled")
    fun oidcFilterChain(
        http: HttpSecurity,
        oidcLoginSuccessHandler: OidcLoginSuccessHandler,
        oidcLogoutHandler: OidcLogoutHandler,
    ): SecurityFilterChain =
        http
            .securityMatcher("/oauth2/**", "/login/oauth2/**", "/logout/connect/back-channel/**")
            .oauth2Login {
                it.successHandler(oidcLoginSuccessHandler)
            }.oidcLogout { it ->
                it.backChannel {
                    it.logoutHandler(oidcLogoutHandler)
                }
            }.build()

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
            .exceptionHandling { it.authenticationEntryPoint(applicationAuthenticationEntryPoint) }
            .authorizeHttpRequests {
                it
                    // Actuator
                    .requestMatchers("/actuator/**")
                    .permitAll()
                    // Auth endpoints
                    .requestMatchers("/api/auth/login", "/api/auth/refresh", "/api/auth/register")
                    .permitAll()
                    // User endpoints
                    .requestMatchers("/api/user/password-reset/start", "/api/user/password-reset/reset")
                    .permitAll()
                    .requestMatchers("/api/user/verification", "/api/user/verification/resend-email")
                    .permitAll()
                    .anyRequest()
                    .authenticated()
            }.with(jwtAuthenticationConfigurer)

        return http.build()
    }
}
