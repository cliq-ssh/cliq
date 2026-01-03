package app.cliq.backend.session

import jakarta.transaction.Transactional
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying

interface SessionRepository : JpaRepository<Session, Long> {
    fun findByApiKey(apiKey: String): Session?

    fun findByOidcSessionId(oidcSessionId: String): Session?

    fun findByUserId(userId: Long): MutableList<Session>

    @Modifying
    @Transactional
    fun deleteAllByUserId(userId: Long): Int

    @Modifying
    @Transactional
    fun deleteByOidcSessionId(oidcSessionId: String): Int
}
