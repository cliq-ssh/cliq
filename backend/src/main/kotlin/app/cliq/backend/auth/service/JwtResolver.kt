package app.cliq.backend.auth.service

import app.cliq.backend.auth.jwt.JwtClaims
import app.cliq.backend.session.Session
import app.cliq.backend.session.SessionRepository
import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.stereotype.Service
import kotlin.jvm.optionals.getOrNull

@Service
class JwtResolver(
    private val jwtDecoder: JwtDecoder,
    private val sessionRepository: SessionRepository,
) {
    fun resolveSessionFromJwt(jwtAccessToken: String): Session {
        val jwt = jwtDecoder.decode(jwtAccessToken)
        val sessionId = jwt.getClaim<Long>(JwtClaims.SID)
        val session = sessionRepository.findById(sessionId).getOrNull()
            ?: throw BadCredentialsException("Invalid JWT Access Token")

        return session
    }
}
