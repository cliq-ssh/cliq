package app.cliq.backend.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.ProviderManager
import org.springframework.security.authentication.dao.DaoAuthenticationProvider
import org.springframework.security.config.Customizer
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.http.SessionCreationPolicy
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.crypto.argon2.Argon2PasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder
import org.springframework.security.web.SecurityFilterChain
import javax.crypto.spec.SecretKeySpec

const val SALT_LENGTH = 16
const val HASH_LENGTH = 32
const val PARALLELISM = 4
const val MEMORY = 1 shl 14
const val ITERATIONS = 3

const val JWT_ALGORITHM = "HmacSHA256"

@Configuration
@EnableWebSecurity
@EnableMethodSecurity
class SecurityConfig {
    @Bean
    fun passwordEncoder(): PasswordEncoder =
        Argon2PasswordEncoder(SALT_LENGTH, HASH_LENGTH, PARALLELISM, MEMORY, ITERATIONS)

    @Bean
    fun securityFilterChain(http: HttpSecurity, oidcProperties: OidcProperties): SecurityFilterChain {
        var chainBuilder = http
            .csrf { it.disable() }
            .formLogin { it.disable() }
            .httpBasic { it.disable() }
            .sessionManagement { it.sessionCreationPolicy(SessionCreationPolicy.STATELESS) }

        if (oidcProperties.enabled) {
            chainBuilder = chainBuilder.oauth2ResourceServer { it.jwt(Customizer.withDefaults()) }
        }

        return chainBuilder.build()
    }


    @Bean
    fun authenticationManager(
        userDetailsService: UserDetailsService,
        passwordEncoder: PasswordEncoder,
    ): AuthenticationManager {
        val provider = DaoAuthenticationProvider(userDetailsService)
        provider.setPasswordEncoder(passwordEncoder)

        return ProviderManager(provider)
    }

    @Bean
    fun jwtEncoder(
        jwtProperties: JwtProperties,
    ): JwtEncoder {
        val key = SecretKeySpec(
            jwtProperties.secret.toByteArray(),
            JWT_ALGORITHM,
        )

        return NimbusJwtEncoder.withSecretKey(key).build()
    }
}
