package app.cliq.backend.config

import app.cliq.backend.pebble.HtmlExtension
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class PebbleConfig {
    @Bean
    fun htmlExtension() = HtmlExtension()
}
