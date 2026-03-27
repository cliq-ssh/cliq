package app.cliq.backend.unit.user

import app.cliq.backend.constants.EXAMPLE_EMAIL
import app.cliq.backend.constants.EXAMPLE_USERNAME
import app.cliq.backend.user.User
import java.time.OffsetDateTime

abstract class AbstractUserTests {
    protected fun createTestUser(
        emailVerificationToken: String? = null,
        emailVerificationSentAt: OffsetDateTime? = null,
        emailVerifiedAt: OffsetDateTime? = null,
        keyRotationToken: String? = null,
        keyRotationSentAt: OffsetDateTime? = null,
        oidcSub: String? = null,
    ): User = User(
        id = 1L,
        oidcSub = oidcSub,
        email = EXAMPLE_EMAIL,
        name = EXAMPLE_USERNAME,
        emailVerifiedAt = emailVerifiedAt,
        emailVerificationToken = emailVerificationToken,
        emailVerificationSentAt = emailVerificationSentAt,
        keyRotationToken = keyRotationToken,
        keyRotationSentAt = keyRotationSentAt,
        createdAt = OffsetDateTime.now(),
        updatedAt = OffsetDateTime.now(),
    )
}
