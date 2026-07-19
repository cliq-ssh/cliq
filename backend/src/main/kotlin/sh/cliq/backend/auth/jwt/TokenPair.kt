package sh.cliq.backend.auth.jwt

import org.springframework.security.oauth2.jwt.Jwt
import sh.cliq.backend.session.Session

data class TokenPair(val jwt: Jwt, val refreshToken: String, val session: Session) {
    companion object {
        fun fromIssuedRefreshToken(jwt: Jwt, issuedRefreshToken: IssuedRefreshToken): TokenPair =
            TokenPair(jwt, issuedRefreshToken.tokenValue, issuedRefreshToken.session)
    }
}
