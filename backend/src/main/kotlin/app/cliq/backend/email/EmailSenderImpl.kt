package app.cliq.backend.email

import app.cliq.backend.config.feature.email.FeatureEmail
import app.cliq.backend.config.properties.EmailProperties
import io.pebbletemplates.pebble.PebbleEngine
import jakarta.mail.internet.InternetAddress
import org.slf4j.LoggerFactory
import org.springframework.mail.MailException
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.mail.javamail.MimeMessageHelper
import org.springframework.stereotype.Service
import java.io.StringWriter
import java.nio.charset.StandardCharsets
import java.util.Locale

@FeatureEmail
@Service
class EmailSenderImpl(
    private val emailProperties: EmailProperties,
    private val pebbleEngine: PebbleEngine,
    private val mailSender: JavaMailSender?,
) : EmailSender {
    private val logger = LoggerFactory.getLogger(this::class.java)

    override fun isEnabled(): Boolean {
        if (emailProperties.enabled && mailSender == null) {
            logger.warn("Email is enabled but mailSender is null")
        }

        return emailProperties.enabled && mailSender != null
    }

    override fun sendEmail(
        to: String,
        subject: String,
        context: Map<String, Any>,
        locale: Locale,
        templateName: String,
    ) {
        if (!isEnabled()) {
            throw IllegalStateException("Email service is disabled")
        }

        val mutableContext = context.toMutableMap()

        mutableContext["lang"] = locale.language
        mutableContext["subject"] = subject

        try {
            val fromAddress =
                emailProperties.fromAddress
                    ?: throw IllegalStateException("From address is not configured")
            val fromName = emailProperties.fromName

            val htmlTemplate = pebbleEngine.getTemplate("emails/$templateName.html")
            val textTemplate = pebbleEngine.getTemplate("emails/$templateName.txt")

            val htmlContentWriter = StringWriter()
            val textContentWriter = StringWriter()

            htmlTemplate.evaluate(htmlContentWriter, mutableContext)
            textTemplate.evaluate(textContentWriter, mutableContext)

            val htmlContent = htmlContentWriter.toString()
            val textContent = textContentWriter.toString()

            if (htmlContent.isBlank() && textContent.isBlank()) {
                logger.error(
                    "Both HTML and text content are empty for email to $to with subject '$subject'. Not sending email.",
                )
                return
            }

            val message = mailSender!!.createMimeMessage()
            val helper = MimeMessageHelper(message, true, StandardCharsets.UTF_8.name())

            helper.setTo(to)
            helper.setSubject(subject)
            helper.setFrom(InternetAddress(fromAddress, fromName))

            helper.setText(textContent, htmlContent)

            mailSender.send(message)

            logger.info("Email sent to $to with subject '$subject'")
        } catch (e: MailException) {
            logger.error("Failed to send email to $to with subject '$subject'", e)

            throw e
        }
    }
}
