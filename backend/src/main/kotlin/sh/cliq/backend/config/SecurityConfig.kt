package sh.cliq.backend.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.core.annotation.Order
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.web.SecurityFilterChain
import sh.cliq.backend.config.feature.oidc.FeatureOidc
import sh.cliq.backend.config.security.exception.handler.ApplicationAuthenticationEntryPoint
import sh.cliq.backend.config.security.jwt.JwtAuthenticationConfigurer
import sh.cliq.backend.config.security.oidc.OidcLoginSuccessHandler
import sh.cliq.backend.config.security.oidc.OidcLogoutHandler

@Configuration
@EnableMethodSecurity
class SecurityConfig(
    private val jwtAuthenticationConfigurer: JwtAuthenticationConfigurer,
    private val applicationAuthenticationEntryPoint: ApplicationAuthenticationEntryPoint,
) {
    @FeatureOidc
    @Bean
    @Order(2)
    fun oidcFilterChain(
        http: HttpSecurity,
        oidcLoginSuccessHandler: OidcLoginSuccessHandler,
        oidcLogoutHandler: OidcLogoutHandler,
    ): SecurityFilterChain = http
        .securityMatcher("/oauth2/**", "/login/oauth2/**", "/logout/connect/back-channel/**")
        .oauth2Login {
            it.successHandler(oidcLoginSuccessHandler)
        }.oidcLogout {
            it.backChannel {
                it.logoutHandler(oidcLogoutHandler)
            }
        }.build()

    @Bean
    @Order(1)
    fun securityFilterChain(http: HttpSecurity): SecurityFilterChain {
        http
            .securityMatcher("/api/**", "/actuator/**")
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
                    // OpenAPI
                    .requestMatchers("/api", "/api/openapi/**")
                    .permitAll()
                    // Auth endpoints
                    .requestMatchers(
                        "/api/auth/login/*",
                        "/api/auth/refresh",
                        "/api/auth/register",
                        "/api/auth/oidc/callback",
                        "/api/auth/device/register",
                    ).permitAll()
                    // User endpoints
                    .requestMatchers("/api/user/password-reset/start", "/api/user/password-reset/reset")
                    .permitAll()
                    .requestMatchers("/api/user/verification", "/api/user/verification/resend-email")
                    .permitAll()
                    .requestMatchers("/api/user/key-rotation/start", "/api/user/key-rotation/verify")
                    .permitAll()
                    // Server Configuration
                    .requestMatchers("/api/server/configuration")
                    .permitAll()
                    // Deny all by default
                    .anyRequest()
                    .authenticated()
            }.with(jwtAuthenticationConfigurer)

        return http.build()
    }
}
