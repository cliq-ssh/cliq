package sh.cliq.backend.preferences.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import sh.cliq.backend.preferences.entity.Preferences
import sh.cliq.backend.user.User
import java.time.OffsetDateTime

interface PreferencesRepository : JpaRepository<Preferences, Long> {
    fun findByUser(user: User): Preferences?

    @Query("SELECT p.updatedAt FROM Preferences p WHERE p.user = :user")
    fun getUpdatedAtByUserId(user: User): OffsetDateTime?
}
