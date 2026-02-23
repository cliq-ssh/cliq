package app.cliq.backend.auth

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import java.time.OffsetDateTime

interface AuthExchangeRepository : JpaRepository<AuthExchange, Long> {
    fun findByExchangeCode(exchangeCode: String): AuthExchange?

    @Query("SELECT ae FROM AuthExchange ae WHERE ae.expiresAt < :now")
    fun getExpiredAuthExchanges(now: OffsetDateTime): List<AuthExchange>
}
