package app.cliq.backend.acceptance.auth.oidc

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import org.junit.jupiter.api.Disabled
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.web.servlet.MockMvc

@AcceptanceTest
class OidcLoginTests(
    @Autowired private val mockMvc: MockMvc,
) : AcceptanceTester() {
    @Test
    @Disabled
    fun `test login with oidc`() {
    }
}
