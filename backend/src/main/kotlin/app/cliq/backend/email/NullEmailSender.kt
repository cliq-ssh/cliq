package app.cliq.backend.email

import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean
import org.springframework.stereotype.Service
import java.util.Locale

@Service
@ConditionalOnMissingBean(EmailSenderImpl::class)
class NullEmailSender : EmailSender {
    override fun isEnabled(): Boolean = false

    override fun sendEmail(
        to: String,
        subject: String,
        context: Map<String, Any>,
        locale: Locale,
        templateName: String,
    ) {
        // We do nothing
    }
}
