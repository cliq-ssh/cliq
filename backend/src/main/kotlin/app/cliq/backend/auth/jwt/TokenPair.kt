package app.cliq.backend.auth.jwt

import app.cliq.backend.session.Session
import org.springframework.security.oauth2.jwt.Jwt

data class TokenPair(
    val jwt: Jwt,
    val refreshToken: RefreshToken,
    val session: Session,
)
