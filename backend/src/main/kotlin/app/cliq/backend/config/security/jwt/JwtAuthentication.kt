package app.cliq.backend.config.security.jwt

import app.cliq.backend.session.Session
import org.springframework.security.authentication.AbstractAuthenticationToken
import org.springframework.security.core.GrantedAuthority

class JwtAuthentication(
    authorities: Collection<GrantedAuthority>,
    val session: Session?,
    authenticated: Boolean,
    val jwtAccessToken: String?,
) : AbstractAuthenticationToken(authorities) {
    init {
        super.setAuthenticated(authenticated)
    }

    override fun getCredentials(): String? = jwtAccessToken

    override fun getPrincipal(): Session? = session
}
