package app.cliq.backend.config.feature.email

import app.cliq.backend.config.feature.FEATURE_EMAIL_PROPERTY_NAME
import org.springframework.boot.autoconfigure.condition.ConditionalOnBooleanProperty
import org.springframework.boot.mail.autoconfigure.MailSenderAutoConfiguration
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Import

@Configuration
@ConditionalOnBooleanProperty(FEATURE_EMAIL_PROPERTY_NAME)
@Import(MailSenderAutoConfiguration::class)
class EmailAutoConfiguration
