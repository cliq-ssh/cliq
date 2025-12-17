package app.cliq.backend.session.auth

import app.cliq.backend.config.JwtProperties
import org.springframework.security.core.Authentication
import org.springframework.security.oauth2.jwt.JwtClaimsSet
import org.springframework.security.oauth2.jwt.JwtEncoder
import org.springframework.security.oauth2.jwt.JwtEncoderParameters
import org.springframework.stereotype.Service
import java.time.Instant
import java.time.temporal.ChronoUnit

const val ISSUER = "self"

@Service
class JwtService(
    private val jwtProperties: JwtProperties,
    private val encoder: JwtEncoder,
    private val issuer: String = ISSUER,
) {

    fun generate(auth: Authentication): String {
        val now: Instant = Instant.now()

        return encoder.encode(
            JwtEncoderParameters.from(
                JwtClaimsSet.builder()
                    .issuer(issuer)
                    .issuedAt(now)
                    .expiresAt(now.plus(jwtProperties.expirationInMs, ChronoUnit.MILLIS))
                    .subject(auth.name)
                    .claim(
                        "roles",
                        auth.authorities.map { it.authority }.filter { !it.isNullOrBlank() }
                            .toList()
                    )
                    .build()
            )).tokenValue
    }
}
