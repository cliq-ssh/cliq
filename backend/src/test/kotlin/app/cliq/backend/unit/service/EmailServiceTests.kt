package app.cliq.backend.unit.service

import app.cliq.backend.config.EmailProperties
import app.cliq.backend.service.EmailService
import io.pebbletemplates.pebble.PebbleEngine
import jakarta.mail.internet.MimeMessage
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.Mock
import org.mockito.junit.jupiter.MockitoExtension
import org.mockito.kotlin.any
import org.mockito.kotlin.never
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.springframework.mail.javamail.JavaMailSender
import java.util.Locale
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

@ExtendWith(MockitoExtension::class)
class EmailServiceTests {
    @Mock
    private lateinit var emailProperties: EmailProperties

    @Mock
    private lateinit var mailSender: JavaMailSender

    @Mock
    private lateinit var templateEngine: PebbleEngine

    private lateinit var emailService: EmailService

    @BeforeEach
    fun setUp() {
        emailService = EmailService(emailProperties, templateEngine, mailSender)
    }

    @Test
    fun `isEnabled should return false when email is disabled`() {
        // Arrange
        whenever(emailProperties.enabled).thenReturn(false)

        // Act
        val result = emailService.isEnabled()

        // Assert
        assertFalse(result)
    }

    @Test
    fun `isEnabled should return false when mailSender is null`() {
        // Arrange
        whenever(emailProperties.enabled).thenReturn(true)
        emailService = EmailService(emailProperties, templateEngine, null)

        // Act
        val result = emailService.isEnabled()

        // Assert
        assertFalse(result)
    }

    @Test
    fun `isEnabled should return true when email is enabled and mailSender is not null`() {
        // Arrange
        whenever(emailProperties.enabled).thenReturn(true)

        // Act
        val result = emailService.isEnabled()

        // Assert
        assertTrue(result)
    }

    @Test
    fun `sendEmail should not send email when email is disabled`() {
        // Arrange
        whenever(emailProperties.enabled).thenReturn(false)

        // Act
        emailService.sendEmail(
            to = "test@example.com",
            subject = "Test Subject",
            context = mapOf("key" to "value"),
            templateName = "test",
            locale = Locale.ENGLISH,
        )

        // Assert
        verify(mailSender, never()).send(any<MimeMessage>())
    }

    @Test
    fun `sendEmail should throw exception when fromAddress is null`() {
        // Arrange
        whenever(emailProperties.enabled).thenReturn(true)
        whenever(emailProperties.fromAddress).thenReturn(null)

        // Act & Assert
        try {
            emailService.sendEmail(
                to = "test@example.com",
                subject = "Test Subject",
                context = mapOf("key" to "value"),
                templateName = "test",
                locale = Locale.ENGLISH,
            )
        } catch (e: IllegalStateException) {
            assertEquals("From address is not configured", e.message)
        }
    }
}
