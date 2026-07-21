package sh.cliq.backend.auth.service

import org.springframework.security.authentication.BadCredentialsException
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.stereotype.Service
import sh.cliq.backend.auth.jwt.JwtClaims
import sh.cliq.backend.session.Session
import sh.cliq.backend.session.SessionRepository
import sh.cliq.backend.utils.TokenUtils
import kotlin.jvm.optionals.getOrNull

@Service
class JwtResolver(
    private val jwtDecoder: JwtDecoder,
    private val sessionRepository: SessionRepository,
    private val tokenUtils: TokenUtils,
) {
    fun resolveSessionFromJwt(jwtAccessToken: String): Session {
        val jwt = jwtDecoder.decode(jwtAccessToken)
        val sessionId = jwt.getClaim<Long>(JwtClaims.SID) ?: throw BadCredentialsException("Invalid JWT Access Token")
        val session =
            sessionRepository.findById(sessionId).getOrNull()
                ?: throw BadCredentialsException("Invalid JWT Access Token")

        return session
    }

    fun resolveSessionFromRefreshToken(refreshToken: String): Session? {
        val hashedRefreshToken = tokenUtils.hashTokenUsingSha512(refreshToken)

        return sessionRepository.findByRefreshToken(hashedRefreshToken)
    }
}
