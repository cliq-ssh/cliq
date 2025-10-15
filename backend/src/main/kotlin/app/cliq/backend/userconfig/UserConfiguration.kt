package app.cliq.backend.userconfig

import app.cliq.backend.user.User
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
import java.time.OffsetDateTime

@Entity
@Table(
    name = "user_configurations",
    uniqueConstraints = [UniqueConstraint(columnNames = ["user_id"])],
)
class UserConfiguration(
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = false)
    var user: User,
    @Column var encryptedConfig: String,
    @Column(nullable = false) var createdAt: OffsetDateTime,
    @Column(nullable = false) var updatedAt: OffsetDateTime,
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,
)
