package app.cliq.backend.auth

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Modifying
import org.springframework.data.jpa.repository.Query
import java.time.OffsetDateTime

interface AuthExchangeRepository : JpaRepository<AuthExchange, Long> {
    fun findByExchangeCode(exchangeCode: String): AuthExchange?

    @Query("DELETE FROM AuthExchange ae WHERE ae.expiresAt < :now")
    @Modifying
    fun deleteExpiredAuthExchanges(now: OffsetDateTime): Long
}
