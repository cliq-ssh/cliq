package app.cliq.backend.auth

import org.springframework.stereotype.Service

@Service
class AuthUserFactory {
    fun createApiKeyUser(
        userId: Long,
        email: String,
        password: String,
    ): AuthUser =
        create(
            userId = userId,
            email = email,
            password = password,
            authUserType = AuthUserType.API_TOKEN,
        )

    fun createOAuthUser(
        userId: Long,
        email: String,
    ): AuthUser =
        create(
            userId = userId,
            email = email,
            password = null,
            authUserType = AuthUserType.OAUTH,
        )

    private fun create(
        userId: Long,
        email: String,
        password: String?,
        authUserType: AuthUserType,
    ): AuthUser =
        AuthUser(
            userId,
            email,
            password?.let {
                PasswordHashWrapper(it)
            },
            authUserType,
        )
}
