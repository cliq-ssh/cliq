package app.cliq.backend.config.messagesource

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.MessageSource
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.support.ReloadableResourceBundleMessageSource

@Configuration
class YamlMessageSourceConfig(
    @Value($$"${spring.messages.basename}")
    private val basename: String,
    @Value($$"${spring.messages.encoding}")
    private val encoding: String,
) {
    @Bean
    fun messageSource(): MessageSource {
        val messageSource = ReloadableResourceBundleMessageSource()
        messageSource.setBasename(basename)
        messageSource.setDefaultEncoding(encoding)
        messageSource.setPropertiesPersister(YamlPropertiesLoader())
        messageSource.setFileExtensions(listOf(".yaml"))

        return messageSource
    }
}
