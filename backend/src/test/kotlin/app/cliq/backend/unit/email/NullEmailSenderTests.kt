package app.cliq.backend.unit.email

import app.cliq.backend.email.NullEmailSender
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import java.util.Locale
import kotlin.test.assertFalse

class NullEmailSenderTests {
    private var classUnderTest = NullEmailSender()

    @Test
    fun `isEnabled should always return false`() {
        assertFalse(classUnderTest.isEnabled())
    }

    @Test
    fun `sendEmail should do nothing`() {
        assertDoesNotThrow {
            classUnderTest.sendEmail(
                "",
                "",
                mapOf(),
                Locale.GERMAN,
                "",
            )
        }
    }
}
