package app.cliq.backend.api.session

import org.springframework.data.jpa.repository.JpaRepository

interface SessionRepository : JpaRepository<Session, Long> {
    fun findByApiKey(apiKey: String): Session?

    fun findByUserId(userId: Long): MutableList<Session>

    fun deleteAllByUserId(userId: Long): Int
}
