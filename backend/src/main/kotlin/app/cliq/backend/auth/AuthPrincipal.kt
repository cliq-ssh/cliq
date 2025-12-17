package app.cliq.backend.auth

import app.cliq.backend.user.User

data class AuthPrincipal(
    val user: User,
    val provider: String,
    val rawToken: String? = null,
)
