package app.cliq.backend.session

import app.cliq.backend.user.User
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.Id
import jakarta.persistence.Index
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import java.time.OffsetDateTime

@Entity
@Table(
    name = "sessions",
    indexes = [
        Index(name = "idx_sessions_user_id", columnList = "user_id"),
        Index(name = "idx_sessions_api_key", columnList = "api_key"),
    ],
)
class Session(
    @Id
    var id: Long = 0,
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = false)
    var user: User,
    @Column(nullable = false, unique = true)
    var apiKey: String,
    @Column
    var name: String? = null,
    @Column
    var userAgent: String? = null,
    @Column
    var lastAccessedAt: OffsetDateTime? = null,
    @Column(nullable = false)
    var createdAt: OffsetDateTime,
    @Column(nullable = false)
    var updatedAt: OffsetDateTime,
)
