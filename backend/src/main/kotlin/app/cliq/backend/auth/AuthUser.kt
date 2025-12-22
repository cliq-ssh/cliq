package app.cliq.backend.auth

import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.oauth2.core.user.OAuth2User

class AuthUser(
    val userId: Long,
    val email: String,
    val passwordHashWrapper: PasswordHashWrapper?,
    val authUserType: AuthUserType,
) : OAuth2User,
    UserDetails {
    override fun getAttributes(): Map<String?, Any?> = emptyMap()

    override fun getAuthorities(): Collection<GrantedAuthority> = emptyList()

    override fun getName(): String = userId.toString()

    override fun getPassword(): String? = passwordHashWrapper?.hash

    override fun getUsername(): String = email

    fun isInternalUser(): Boolean = authUserType == AuthUserType.API_TOKEN
}
