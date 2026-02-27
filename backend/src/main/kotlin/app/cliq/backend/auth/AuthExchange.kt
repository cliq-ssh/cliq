package app.cliq.backend.auth

import app.cliq.backend.session.Session
import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.GeneratedValue
import jakarta.persistence.GenerationType
import jakarta.persistence.Id
import jakarta.persistence.Index
import jakarta.persistence.JoinColumn
import jakarta.persistence.OneToOne
import jakarta.persistence.Table
import java.net.InetAddress
import java.time.OffsetDateTime

@Entity
@Table(
    name = "auth_exchanges",
    indexes = [
        Index(name = "idx_auth_exchanges_exchange_code", columnList = "exchange_code"),
    ],
)
class AuthExchange(
    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(nullable = false, unique = true)
    val session: Session,
    @Column(nullable = false)
    val exchangeCode: String,
    @Column(nullable = false)
    val ipAddress: InetAddress,
    @Column(nullable = false)
    val jwtToken: String,
    @Column(nullable = false)
    val refreshToken: String,
    @Column(nullable = false)
    val createdAt: OffsetDateTime,
    @Column(nullable = false)
    var expiresAt: OffsetDateTime,
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long? = null,
) {
    fun isExpired(now: OffsetDateTime): Boolean = !now.isBefore(expiresAt)
}
