package app.cliq.backend.auth.jwt

import app.cliq.backend.session.Session

data class IssuedRefreshToken(
    val tokenValue: String,
    val session: Session,
)
