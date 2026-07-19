package sh.cliq.backend.user.listener

import jakarta.persistence.PreUpdate
import org.springframework.stereotype.Component
import sh.cliq.backend.user.User
import java.time.Clock
import java.time.OffsetDateTime

@Component
class UserEntityListener(private val clock: Clock) {
    @PreUpdate
    private fun updateUpdatedAt(user: User) {
        user.updatedAt = OffsetDateTime.now(clock)
    }
}
