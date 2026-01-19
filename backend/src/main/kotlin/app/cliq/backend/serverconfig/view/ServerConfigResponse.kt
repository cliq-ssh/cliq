package app.cliq.backend.serverconfig.view

import app.cliq.backend.config.properties.AuthProperties

data class ServerConfigResponse(
    val serverVersion: String,
    val oidcUrl: String? = null,
    val localAuthProperties: AuthProperties.LocalAuthProperties,
)
