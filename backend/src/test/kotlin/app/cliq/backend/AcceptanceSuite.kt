package app.cliq.backend

import app.cliq.backend.support.DatabaseCleanupService
import com.icegreen.greenmail.configuration.GreenMailConfiguration
import com.icegreen.greenmail.junit5.GreenMailExtension
import com.icegreen.greenmail.util.ServerSetupTest
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.extension.RegisterExtension
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.context.annotation.ComponentScan
import org.springframework.test.context.ActiveProfiles

const val EMAIL = "cliq@localhost"
const val EMAIL_PWD = "cliq"
const val SMTP_HOST = "127.0.0.1"
const val SMTP_PORT = 3025

@SpringBootTest(
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
@AutoConfigureMockMvc
@ComponentScan(basePackages = ["app.cliq.backend.support"])
@ActiveProfiles("test")
annotation class AcceptanceTest

@AcceptanceTest
abstract class AcceptanceTester {
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

    @AfterEach
    fun clearDatabase(
        @Autowired cleaner: DatabaseCleanupService,
    ) {
        cleaner.truncate()
    }
}
