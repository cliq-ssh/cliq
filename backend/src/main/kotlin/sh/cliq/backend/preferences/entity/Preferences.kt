package sh.cliq.backend.preferences.entity

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.OneToOne
import jakarta.persistence.Table
import jakarta.persistence.UniqueConstraint
import sh.cliq.backend.user.User
import java.time.OffsetDateTime

@Entity
@Table(
    name = "preferences",
    uniqueConstraints = [UniqueConstraint(columnNames = ["user_id"])],
)
class Preferences(
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = false)
    var user: User,
    @Column var encryptedPreferences: String,
    @Column(nullable = false) var version: String,
    @Column(nullable = false) var createdAt: OffsetDateTime,
    @Column(nullable = false) var updatedAt: OffsetDateTime,
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,
)
