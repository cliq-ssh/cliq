package app.cliq.backend.unit.user.oidc

import app.cliq.backend.unit.user.AbstractUserTests
import org.junit.jupiter.api.Test
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class UserIsOidcTests : AbstractUserTests() {
    @Test
    fun `isOidc is true when sub is set`() {
        val oidcUser = createTestUser(oidcSub = "Test-OIDC-123")
        assertTrue(oidcUser.isOidcUser())

        val nonOidcUser = createTestUser(oidcSub = null)
        assertFalse(nonOidcUser.isOidcUser())
    }
}
