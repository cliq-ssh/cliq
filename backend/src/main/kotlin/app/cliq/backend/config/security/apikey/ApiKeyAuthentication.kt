package app.cliq.backend.config.security.apikey

import app.cliq.backend.user.User
import org.springframework.security.authentication.AbstractAuthenticationToken
import org.springframework.security.core.GrantedAuthority

class ApiKeyAuthentication(
    authorities: Collection<GrantedAuthority>,
    val user: User?,
    authenticated: Boolean,
    val apiKey: String?,
) : AbstractAuthenticationToken(authorities) {
    init {
        super.setAuthenticated(authenticated)
    }

    override fun getCredentials(): String? = apiKey

    override fun getPrincipal(): User? = user
}
