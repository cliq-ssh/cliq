package app.cliq.backend.auth

import app.cliq.backend.session.Session
import org.springframework.security.core.Authentication
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.AuthorityUtils

class BearerTokenAuthentication(
    private val session: Session,
    private val token: String,
    private var isAuthenticated: Boolean,
) : Authentication {
    override fun getName(): String = session.name ?: session.id.toString()

    override fun getAuthorities(): Collection<GrantedAuthority> = AuthorityUtils.NO_AUTHORITIES

    override fun getCredentials(): String = token

    override fun getDetails(): Session = session

    override fun getPrincipal(): Session = session

    override fun isAuthenticated(): Boolean = isAuthenticated

    override fun setAuthenticated(isAuthenticated: Boolean) {
        this.isAuthenticated = isAuthenticated
    }
}
