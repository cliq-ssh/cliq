package sh.cliq.backend.serverconfig.view

import sh.cliq.backend.config.properties.AuthProperties

data class ServerConfigResponse(
    val serverVersion: String,
    val oidcUrl: String? = null,
    val localAuthProperties: AuthProperties.LocalAuthProperties,
    val authExchangeDurationSeconds: Long,
    val emailEnabled: Boolean,
)
