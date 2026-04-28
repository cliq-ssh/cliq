package app.cliq.backend.serverconfig.factory

import app.cliq.backend.config.feature.FeatureUtils
import app.cliq.backend.config.feature.Features
import app.cliq.backend.config.properties.AuthProperties
import app.cliq.backend.config.properties.InfoProperties
import app.cliq.backend.constants.Oidc
import app.cliq.backend.serverconfig.view.ServerConfigResponse
import org.springframework.stereotype.Service

@Service
class ServerConfigResponseFactory(
    private val featureUtils: FeatureUtils,
    private val infoProperties: InfoProperties,
    private val authProperties: AuthProperties,
) {
    fun getResponse(): ServerConfigResponse {
        if (featureUtils.isFeatureActive(Features.OIDC)) {
            return createResponse(Oidc.AUTHORIZATION_ENDPOINT)
        }

        return createResponse()
    }

    private fun createResponse(oidcUrl: String? = null): ServerConfigResponse = ServerConfigResponse(
        serverVersion = infoProperties.version,
        oidcUrl = oidcUrl,
        localAuthProperties = authProperties.local,
        authExchangeDurationSeconds = authProperties.authExchangeDurationSeconds,
    )
}
