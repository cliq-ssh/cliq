package sh.cliq.backend.acceptance.email

import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.context.TestPropertySource
import sh.cliq.backend.acceptance.AcceptanceTest
import sh.cliq.backend.acceptance.AcceptanceTester
import sh.cliq.backend.email.EmailSender
import sh.cliq.backend.email.EmailSenderImpl
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
