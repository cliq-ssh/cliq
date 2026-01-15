package app.cliq.backend.acceptance.email

import app.cliq.backend.acceptance.EmailAcceptanceTest
import app.cliq.backend.acceptance.EmailAcceptanceTester
import app.cliq.backend.email.EmailService
import jakarta.mail.internet.MimeMessage
import org.apache.commons.mail2.jakarta.util.MimeMessageParser
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import java.util.Locale
import kotlin.test.assertTrue

@EmailAcceptanceTest
class EmailServiceTests(
    @Autowired
    private val emailService: EmailService,
) : EmailAcceptanceTester() {
    @Test
    fun `isEnabled should return true`() {
        assertTrue(emailService.isEnabled())
    }

    @Test
    fun `sendEmail should render templates and send email with proper content`() {
        // Verify email service is enabled
        assertTrue(emailService.isEnabled())

        // Test data
        val toEmail = "test@example.com"
        val subject = "Test Email"
        val templateName = "testEmail"
        val context =
            mapOf(
                "subject" to subject,
                "userName" to "John Doe",
                "message" to "Hello World",
            )
        val locale = Locale.ENGLISH

        // Send email
        emailService.sendEmail(
            to = toEmail,
            subject = subject,
            context = context,
            locale = locale,
            templateName = templateName,
        )

        assertTrue(greenMail.waitForIncomingEmail(1))

        val receivedMessages = greenMail.receivedMessages

        val message = receivedMessages[0]
        Assertions.assertEquals(subject, message.subject)
        Assertions.assertEquals(message.allRecipients.size, 1)
        Assertions.assertEquals(toEmail, message.allRecipients[0].toString())

        // Verify content types exist (both HTML and text)
        assertTrue(message.contentType.contains("multipart/mixed"))

        val parser =
            MimeMessageParser(message as MimeMessage)
                .parse()

        assertTrue(parser.hasHtmlContent())
        assertTrue(parser.hasPlainContent())

        val textContent = parser.plainContent
        val htmlContent = parser.htmlContent

        // Verify Text content
        assertTrue(textContent.contains("John Doe"))
        assertTrue(textContent.contains("Hello World"))

        // Verify HTML content
        assertTrue(htmlContent.contains("<html lang=\"en\">"))
        assertTrue(htmlContent.contains("John Doe"))
        assertTrue(htmlContent.contains("Hello World"))

        // Verify that HTML and text content are different
        assertTrue(textContent != htmlContent, "Text and HTML content should not be the same")
    }
}
