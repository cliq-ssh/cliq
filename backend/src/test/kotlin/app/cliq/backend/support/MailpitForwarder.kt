package app.cliq.backend.support

import com.icegreen.greenmail.junit5.GreenMailExtension
import org.springframework.beans.factory.annotation.Value
import org.springframework.boot.test.context.TestComponent
import org.springframework.mail.javamail.JavaMailSender
import org.springframework.mail.javamail.JavaMailSenderImpl
import java.util.concurrent.CompletableFuture
import java.util.concurrent.Executors

@TestComponent
class MailpitForwarder(
    @Value("\${MAIL_HOST}")
    mailpitSmtpHost: String,
    @Value("\${MAIL_PORT}")
    mailpitSmtpPort: Int,
) {
    private val mailpitMailSender: JavaMailSender = createMailpitSender(mailpitSmtpHost, mailpitSmtpPort)

    companion object {
        private fun createMailpitSender(mailpitSmtpHost: String, mailpitSmtpPort: Int): JavaMailSender {
            val mailSender = JavaMailSenderImpl()
            mailSender.host = mailpitSmtpHost
            mailSender.port = mailpitSmtpPort

            val props = mailSender.javaMailProperties
            props["mail.transport.protocol"] = "smtp"
            props["mail.smtp.auth"] = "false"
            props["mail.smtp.starttls.enable"] = "false"
            props["mail.debug"] = "false"
            mailSender.javaMailProperties = props

            return mailSender
        }
    }

    fun forwardMailsToMailpit(greenMail: GreenMailExtension) {
        if (greenMail.receivedMessages.isEmpty()) return

        Executors.newVirtualThreadPerTaskExecutor().use { executor ->
            val futures = greenMail.receivedMessages.map { message ->
                CompletableFuture.runAsync({ mailpitMailSender.send(message) }, executor)
            }
            CompletableFuture.allOf(*futures.toTypedArray()).join()
        }
    }
}
