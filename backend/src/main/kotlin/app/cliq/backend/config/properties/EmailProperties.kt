package app.cliq.backend.config.properties

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app.email")
class EmailProperties {
    var enabled: Boolean = false
    var fromAddress: String? = null
    var fromName: String = "CLIq"
}
