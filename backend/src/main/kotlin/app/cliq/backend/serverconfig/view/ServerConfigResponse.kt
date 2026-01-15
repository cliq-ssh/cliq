package app.cliq.backend.serverconfig.view

data class ServerConfigResponse(
    val serverVersion: String,
    val oidcUrl: String? = null,
)
