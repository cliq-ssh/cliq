package app.cliq.backend.config

import app.cliq.backend.config.oidc.OidcProperties
import app.cliq.backend.config.oidc.OidcUrlResolver
import io.swagger.v3.oas.annotations.enums.SecuritySchemeIn
import io.swagger.v3.oas.annotations.enums.SecuritySchemeType
import io.swagger.v3.oas.annotations.security.SecurityScheme
import io.swagger.v3.oas.models.Components
import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.info.Info
import io.swagger.v3.oas.models.security.OAuthFlow
import io.swagger.v3.oas.models.security.OAuthFlows
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.http.HttpHeaders
import tools.jackson.databind.ObjectMapper
import io.swagger.v3.oas.models.security.SecurityScheme as SecuritySchemeModel

const val API_TOKEN_SECURITY_SCHEME_NAME = "API Token"
const val OIDC_SECURITY_SCHEME_NAME = "oidc"

@Configuration
@SecurityScheme(
    name = API_TOKEN_SECURITY_SCHEME_NAME,
    type = SecuritySchemeType.APIKEY,
    bearerFormat = "API_KEY",
    scheme = "bearer",
    `in` = SecuritySchemeIn.HEADER,
    paramName = HttpHeaders.AUTHORIZATION,
)
class OpenApiConfig(
    private val infoProperties: InfoProperties,
    private val oidcProperties: OidcProperties,
    private val objectMapper: ObjectMapper,
) {
    @Bean
    fun apiDocConfig(): OpenAPI {
        val openApi =
            OpenAPI()
                .info(
                    Info()
                        .title(infoProperties.name)
                        .version(infoProperties.version)
                        .description(infoProperties.description),
                )

        if (oidcProperties.enabled) {
            val oidcUrlResolver = OidcUrlResolver(oidcProperties, objectMapper)
            val oauthFlow =
                OAuthFlow()
                    .authorizationUrl(oidcUrlResolver.getAuthUrl())
                    .tokenUrl(oidcUrlResolver.getTokenUrl())
            val flows = OAuthFlows().authorizationCode(oauthFlow)
            val oauthScheme =
                SecuritySchemeModel()
                    .type(SecuritySchemeModel.Type.OAUTH2)
                    .flows(flows)
            val components = Components().addSecuritySchemes(OIDC_SECURITY_SCHEME_NAME, oauthScheme)
            openApi.components(components)
        }

        return openApi
    }
}
