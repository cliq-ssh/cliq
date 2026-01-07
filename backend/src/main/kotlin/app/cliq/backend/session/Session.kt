package app.cliq.backend.session

import app.cliq.backend.user.User
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
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
        Index(name = "idx_sessions_oidc_session_id", columnList = "oidc_session_id"),
        Index(name = "idx_sessions_refresh_token", columnList = "refresh_token"),
    ],
)
class Session(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,
    @Column(nullable = true, unique = true)
    var oidcSessionId: String? = null,
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(nullable = false)
    var user: User,
    @Column(nullable = false, unique = true)
    var refreshToken: String, // TODO: hash
    @Column
    var name: String? = null,
    @Column
    var lastUsedAt: OffsetDateTime? = null,
    @Column
    var expiresAt: OffsetDateTime,
    @Column(nullable = false)
    var createdAt: OffsetDateTime,
)
