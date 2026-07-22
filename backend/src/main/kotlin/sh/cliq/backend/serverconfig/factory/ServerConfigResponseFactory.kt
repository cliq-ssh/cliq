package sh.cliq.backend.serverconfig.factory

import org.springframework.stereotype.Service
import sh.cliq.backend.config.feature.FeatureUtils
import sh.cliq.backend.config.feature.Features
import sh.cliq.backend.config.properties.AuthProperties
import sh.cliq.backend.config.properties.InfoProperties
import sh.cliq.backend.constants.Oidc
import sh.cliq.backend.serverconfig.view.ServerConfigResponse

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
        emailEnabled = featureUtils.isFeatureActive(Features.EMAIL),
    )
}
