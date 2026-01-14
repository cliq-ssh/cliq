package app.cliq.backend.unit.user

import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import java.time.OffsetDateTime
import kotlin.test.assertFalse

class UserUsableTests : AbstractUserTests() {
    @Test
    fun `isUsable returns true when email is verified`() {
        val user = createTestUser(emailVerifiedAt = OffsetDateTime.now())

        val usable = user.isUsable()

        assertTrue(usable, "Expected verified user to be usable")
    }

    @Test
    fun `isUsable returns false when email is not verified`() {
        val user = createTestUser(emailVerifiedAt = null)

        val usable = user.isUsable()

        assertFalse(usable, "Expected unverified user be unusable")
    }
}
