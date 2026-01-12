package app.cliq.backend.acceptance

import app.cliq.backend.acceptance.email.EMAIL
import app.cliq.backend.acceptance.email.EMAIL_PWD
import app.cliq.backend.acceptance.email.SMTP_HOST
import app.cliq.backend.acceptance.email.SMTP_PORT
import com.icegreen.greenmail.configuration.GreenMailConfiguration
import com.icegreen.greenmail.junit5.GreenMailExtension
import com.icegreen.greenmail.util.ServerSetupTest
import org.junit.jupiter.api.extension.RegisterExtension
import org.springframework.boot.test.context.SpringBootTest

const val EMAIL = "cliq@localhost"
const val EMAIL_PWD = "cliq"
const val SMTP_HOST = "127.0.0.1"
const val SMTP_PORT = 3025

@AcceptanceTest
@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = [
        "spring.mail.host=${SMTP_HOST}",
        "spring.mail.port=${SMTP_PORT}",
        "spring.mail.username=$EMAIL",
        "spring.mail.password=${EMAIL_PWD}",
        "spring.mail.protocol=smtp",
        "spring.mail.properties.mail.smtp.auth=true",
        "spring.mail.properties.mail.smtp.starttls.enable=false",
        "app.email.enabled=true",
        "app.email.from-address=$EMAIL",
    ],
)
annotation class EmailAcceptanceTest

@EmailAcceptanceTest
abstract class EmailAcceptanceTester : AcceptanceTester() {
    companion object {
        @JvmField
        @RegisterExtension
        val greenMail: GreenMailExtension =
            GreenMailExtension(ServerSetupTest.SMTP_IMAP)
                .withConfiguration(
                    GreenMailConfiguration
                        .aConfig()
                        .withUser(EMAIL, EMAIL_PWD),
                )
    }
}
