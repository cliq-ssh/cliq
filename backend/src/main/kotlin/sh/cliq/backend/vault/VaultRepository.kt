package sh.cliq.backend.vault

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import sh.cliq.backend.user.User
import java.time.OffsetDateTime

interface VaultRepository : JpaRepository<VaultData, Long> {
    fun getByUser(user: User): VaultData?

    @Query("SELECT uc.updatedAt FROM VaultData uc WHERE uc.user = :user")
    fun getUpdatedAtByUser(user: User): OffsetDateTime?
}
