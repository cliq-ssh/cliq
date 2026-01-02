package app.cliq.backend.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app.info")
class InfoProperties(
    val name: String,
    val version: String,
    val description: String,
)
