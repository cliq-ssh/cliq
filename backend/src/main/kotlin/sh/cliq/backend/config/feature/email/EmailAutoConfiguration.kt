package sh.cliq.backend.config.feature.email

import org.springframework.boot.autoconfigure.condition.ConditionalOnBooleanProperty
import org.springframework.boot.mail.autoconfigure.MailSenderAutoConfiguration
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Import
import sh.cliq.backend.config.feature.FEATURE_EMAIL_PROPERTY_NAME

@Configuration
@ConditionalOnBooleanProperty(FEATURE_EMAIL_PROPERTY_NAME)
@Import(MailSenderAutoConfiguration::class)
class EmailAutoConfiguration
