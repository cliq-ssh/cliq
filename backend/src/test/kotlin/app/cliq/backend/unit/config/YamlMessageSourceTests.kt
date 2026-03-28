package app.cliq.backend.unit.config

import app.cliq.backend.config.messagesource.YamlMessageSourceConfig
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.util.Locale

class YamlMessageSourceTests {
    // Keep options in sync with application.yaml
    private val messageSource = YamlMessageSourceConfig("classpath:messages/messages", "UTF-8").messageSource()

    @Test
    fun `loads default locale messages from yaml`() {
        val subject = messageSource.getMessage("email.verification.subject", null, Locale.ENGLISH)
        assertThat(subject).isEqualTo("Verify Your Email Address")
    }

    @Test
    fun `formats placeholders from yaml messages`() {
        val greeting = messageSource.getMessage("email.verification.greeting", arrayOf("Alex"), Locale.ENGLISH)
        assertThat(greeting).isEqualTo("Hello Alex,")
    }

    @Test
    fun `falls back from regional locale to language bundle`() {
        val signature = messageSource.getMessage("email.common.signature", null, Locale.GERMANY)
        assertThat(signature).isEqualTo("Vielen Dank")
    }
}
