package app.cliq.backend.email

import java.util.Locale

interface EmailSender {
    /**
     * Returns true if the email service is enabled and able to send emails.
     */
    fun isEnabled(): Boolean

    /**
     * Sends an email using a Pebble template with both HTML and plain text versions
     * Templates must be available in an HTML and txt format.
     * The locale and subject are automatically added to the context.
     *
     * @param to Recipient email address
     * @param subject Email subject
     * @param context Map of variables to be passed to the template
     * @param templateName Name of the Template (without extension/without .html or .txt)
     */
    fun sendEmail(to: String, subject: String, context: Map<String, Any>, locale: Locale, templateName: String)
}
