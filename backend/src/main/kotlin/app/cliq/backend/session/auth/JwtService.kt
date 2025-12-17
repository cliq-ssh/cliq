package app.cliq.backend.session.auth

import app.cliq.backend.config.JwtProperties
import app.cliq.backend.session.Session
import org.springframework.security.oauth2.jose.jws.MacAlgorithm
import org.springframework.security.oauth2.jose.jws.SignatureAlgorithm
import org.springframework.security.oauth2.jwt.JwsHeader
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

    fun generate(session: Session): String {
        val now: Instant = Instant.now()

        val claims = JwtClaimsSet.builder()
            .issuer(issuer)
            .issuedAt(now)
            .expiresAt(now.plus(jwtProperties.expirationInMs, ChronoUnit.MILLIS))
            .subject(session.user.id.toString())
            .claim("sessionId", session.id)
            .build()

        // ensures "typ": "JWT"
        val header = JwsHeader.with(MacAlgorithm.HS256)
            .type("JWT")
            .build()

        val token = encoder.encode(JwtEncoderParameters.from(header, claims))

        return token.tokenValue
    }
}
