package sh.cliq.backend.vault

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import sh.cliq.backend.user.User
import java.time.OffsetDateTime
import java.util.UUID

interface VaultRepository : JpaRepository<VaultData, UUID> {
    fun findByIdAndUser(id: UUID, user: User): VaultData?

    fun findAllByUser(user: User): MutableList<VaultData>

    @Query("SELECT uc.updatedAt FROM VaultData uc WHERE uc.id = :id AND uc.user = :user")
    fun getUpdatedAtByIdAndUser(id: UUID, user: User): OffsetDateTime?
}
