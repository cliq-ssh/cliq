package app.cliq.backend.instance

import jakarta.persistence.Column
import jakarta.persistence.Entity
import jakarta.persistence.Id
import jakarta.persistence.Table
import java.time.OffsetDateTime

@Entity
@Table(name = "instances")
class Instance(
    @Id val nodeId: UShort,
    @Column(nullable = false) val createdAt: OffsetDateTime,
    @Column(nullable = false) var updatedAt: OffsetDateTime,
)
