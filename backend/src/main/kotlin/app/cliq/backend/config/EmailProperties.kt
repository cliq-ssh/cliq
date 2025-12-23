package app.cliq.backend.config

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.boot.context.properties.ConfigurationProperties
import org.springframework.boot.mail.autoconfigure.MailSenderAutoConfiguration
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Import

@ConfigurationProperties(prefix = "app.email")
class EmailProperties {
    var enabled: Boolean = false
    var fromAddress: String? = null
    var fromName: String = "CLIq"
}

@Configuration
@ConditionalOnProperty(prefix = "app.email", name = ["enabled"], havingValue = "true")
@Import(MailSenderAutoConfiguration::class)
class EmailConfiguration
