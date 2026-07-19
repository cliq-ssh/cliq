package sh.cliq.backend.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.NimbusJwtDecoder
import org.springframework.security.oauth2.jwt.NimbusJwtEncoder
import sh.cliq.backend.config.properties.JwtProperties
import javax.crypto.spec.SecretKeySpec

@Configuration
class JwtConfiguration(jwtProperties: JwtProperties) {
    private val secretKey = SecretKeySpec(jwtProperties.secret.toByteArray(), jwtProperties.algorithm)

    @Bean
    fun jwtEncoder(): JwtEncoder = NimbusJwtEncoder.withSecretKey(secretKey).build()

    @Bean
    fun jwtDecoder(): JwtDecoder = NimbusJwtDecoder.withSecretKey(secretKey).build()
}
