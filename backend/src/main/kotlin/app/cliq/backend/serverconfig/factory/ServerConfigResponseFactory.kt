package app.cliq.backend.serverconfig.factory

import app.cliq.backend.config.properties.AuthProperties
import app.cliq.backend.config.properties.InfoProperties
import app.cliq.backend.constants.Features
import app.cliq.backend.constants.Oidc
import app.cliq.backend.serverconfig.view.ServerConfigResponse
import app.cliq.backend.utils.FeatureUtils
import org.springframework.stereotype.Service

@Service
class ServerConfigResponseFactory(
    private val featureUtils: FeatureUtils,
    private val infoProperties: InfoProperties,
    private val authProperties: AuthProperties,
) {
    fun getResponse(): ServerConfigResponse {
        if (featureUtils.isProfileActive(Features.OIDC)) {
            return createResponse(Oidc.AUTHORIZATION_ENDPOINT)
        }

        return createResponse()
    }

    private fun createResponse(oidcUrl: String? = null): ServerConfigResponse =
        ServerConfigResponse(
            serverVersion = infoProperties.version,
            oidcUrl = oidcUrl,
            localAuthProperties = authProperties.local,
        )
}
