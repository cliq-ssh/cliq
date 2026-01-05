package app.cliq.backend.config

import app.cliq.backend.config.properties.JwtProperties
import com.nimbusds.jose.jwk.source.ImmutableSecret
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder
import javax.crypto.spec.SecretKeySpec


@Configuration
class JwtConfiguration(
    private val jwtProperties: JwtProperties
) {
    @Bean
    fun jwtEncoder(): JwtEncoder {
        val key = SecretKeySpec(jwtProperties.secret.toByteArray(), jwtProperties.algorithm)

        return NimbusJwtEncoder(ImmutableSecret(key))
    }

    @Bean
    fun jwtDecoder(): JwtDecoder {
        val key = SecretKeySpec(jwtProperties.secret.toByteArray(), "HmacSHA256")

        return NimbusJwtDecoder.withSecretKey(key).build()
    }
}
