package app.cliq.backend.unit.unit

import app.cliq.backend.user.User
import java.time.OffsetDateTime

abstract class AbstractUserTests {
    protected fun createTestUser(
        emailVerificationToken: String? = null,
        emailVerificationSentAt: OffsetDateTime? = null,
        resetToken: String? = null,
        resetSentAt: OffsetDateTime? = null,
    ): User =
        User(
            id = 1L,
            email = "test@example.com",
            name = "Test User",
            password = "password",
            emailVerificationToken = emailVerificationToken,
            emailVerificationSentAt = emailVerificationSentAt,
            resetToken = resetToken,
            resetSentAt = resetSentAt,
            createdAt = OffsetDateTime.now(),
            updatedAt = OffsetDateTime.now(),
        )
}
