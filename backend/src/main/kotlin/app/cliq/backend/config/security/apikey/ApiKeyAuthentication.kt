package app.cliq.backend.config.security.apikey

import app.cliq.backend.auth.AuthUser
import org.springframework.security.authentication.AbstractAuthenticationToken
import org.springframework.security.core.GrantedAuthority

class ApiKeyAuthentication(
    authorities: Collection<GrantedAuthority>,
    val authUser: AuthUser?,
    authenticated: Boolean,
    val apiKey: String?,
) : AbstractAuthenticationToken(authorities) {
    init {
        super.setAuthenticated(authenticated)
    }

    override fun getCredentials(): String? = apiKey

    override fun getPrincipal(): AuthUser? = authUser
}
