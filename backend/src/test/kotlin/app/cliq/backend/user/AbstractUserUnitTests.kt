package app.cliq.backend.user

import java.time.OffsetDateTime

abstract class AbstractUserUnitTests {
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
