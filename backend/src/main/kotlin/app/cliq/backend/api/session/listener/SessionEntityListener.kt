package app.cliq.backend.api.session.listener

import app.cliq.backend.api.session.Session
import jakarta.persistence.PreUpdate
import org.springframework.stereotype.Component
import java.time.Clock
import java.time.OffsetDateTime

@Component
class SessionEntityListener(
    private val clock: Clock
) {

    @PreUpdate
    private fun updateUpdatedAt(session: Session) {
        session.updatedAt = OffsetDateTime.now(clock)
    }
}
