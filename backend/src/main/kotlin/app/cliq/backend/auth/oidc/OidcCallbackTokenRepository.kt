package app.cliq.backend.auth.oidc

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository

@Repository
interface OidcCallbackTokenRepository : JpaRepository<OidcCallbackToken, String> {
    fun findByToken(token: String): OidcCallbackToken?
}
