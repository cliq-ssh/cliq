package app.cliq.backend.unit.user

import app.cliq.backend.docs.EXAMPLE_EMAIL
import app.cliq.backend.docs.EXAMPLE_PASSWORD
import app.cliq.backend.docs.EXAMPLE_USERNAME
import app.cliq.backend.user.User
import java.time.OffsetDateTime

abstract class AbstractUserTests {
    protected fun createTestUser(
        emailVerificationToken: String? = null,
        emailVerificationSentAt: OffsetDateTime? = null,
        emailVerifiedAt: OffsetDateTime? = null,
        resetToken: String? = null,
        resetSentAt: OffsetDateTime? = null,
    ): User =
        User(
            id = 1L,
            email = EXAMPLE_EMAIL,
            name = EXAMPLE_USERNAME,
            password = EXAMPLE_PASSWORD,
            emailVerifiedAt = emailVerifiedAt,
            emailVerificationToken = emailVerificationToken,
            emailVerificationSentAt = emailVerificationSentAt,
            resetToken = resetToken,
            resetSentAt = resetSentAt,
            createdAt = OffsetDateTime.now(),
            updatedAt = OffsetDateTime.now(),
        )
}
