package sh.cliq.backend.auth.jwt

import sh.cliq.backend.session.Session

data class IssuedRefreshToken(val tokenValue: String, val session: Session)
