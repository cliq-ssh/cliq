package app.cliq.backend.auth.oidc

import app.cliq.backend.auth.AuthExchange
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Index
import jakarta.persistence.JoinColumn
import jakarta.persistence.MapsId
import jakarta.persistence.OneToOne
import jakarta.persistence.Table
import java.time.OffsetDateTime

@Entity
@Table(
    name = "oidc_callback_token",
    indexes = [
        Index(name = "idx_oidc_callback_token_token", columnList = "token"),
    ],
)
class OidcCallbackToken(
    @OneToOne(fetch = FetchType.EAGER, optional = false)
    @MapsId
    @JoinColumn(nullable = false, unique = true)
    val authExchange: AuthExchange,
    @Column(nullable = true, unique = true)
    val oidcSessionId: String?,
    @Column(nullable = false)
    val token: String,
    @Column(nullable = false)
    val createdAt: OffsetDateTime,
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,
)
