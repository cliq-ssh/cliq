package sh.cliq.backend.config.security.jwt

import org.springframework.security.authentication.AbstractAuthenticationToken
import org.springframework.security.core.GrantedAuthority
import sh.cliq.backend.session.Session

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
