package app.cliq.backend.acceptance.email

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.email.EmailSender
import app.cliq.backend.email.NullEmailSender
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.context.TestPropertySource
import kotlin.test.assertFalse

@AcceptanceTest
@TestPropertySource(properties = ["app.email.enabled=false"])
class EmailDisabledTests(
    @Autowired
    private val emailSender: EmailSender,
) : AcceptanceTester() {
    @Test
    fun `emailSender is null sender`() {
        assert(emailSender is NullEmailSender)
    }

    @Test
    fun `isEnabled should return true`() {
        assertFalse(emailSender.isEnabled())
    }
}
