package sh.cliq.backend.vault

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.FetchType
import jakarta.persistence.Id
import jakarta.persistence.JoinColumn
import jakarta.persistence.ManyToOne
import jakarta.persistence.Table
import sh.cliq.backend.user.User
import java.time.OffsetDateTime
import java.util.UUID

@Entity
@Table(name = "vaults")
class VaultData(
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(nullable = false)
    var user: User,
    @Column var encryptedConfig: String,
    @Column(nullable = false) var version: String,
    @Column(nullable = false) var createdAt: OffsetDateTime,
    @Column(nullable = false) var updatedAt: OffsetDateTime,
    @Id
    var id: UUID,
)
