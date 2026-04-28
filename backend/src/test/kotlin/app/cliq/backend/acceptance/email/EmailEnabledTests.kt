package app.cliq.backend.acceptance.email

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.email.EmailSender
import app.cliq.backend.email.EmailSenderImpl
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.context.TestPropertySource
import kotlin.test.assertTrue

@AcceptanceTest
@TestPropertySource(properties = ["app.email.enabled=true"])
class EmailEnabledTests(
    @Autowired
    private val emailSender: EmailSender,
) : AcceptanceTester() {
    @Test
    fun `emailSender is actual implementation`() {
        assert(emailSender is EmailSenderImpl)
    }

    @Test
    fun `isEnabled should return true`() {
        assertTrue(emailSender.isEnabled())
    }
}
