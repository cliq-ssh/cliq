package app.cliq.backend.config

import io.swagger.v3.oas.annotations.enums.SecuritySchemeType
import io.swagger.v3.oas.annotations.security.SecurityScheme
import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.info.Info
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

const val API_TOKEN_SECURITY_SCHEME_NAME = "API Token"
const val OIDC_SECURITY_SCHEME_NAME = "oidc"

@Configuration
@SecurityScheme(
    name = API_TOKEN_SECURITY_SCHEME_NAME,
    type = SecuritySchemeType.HTTP,
    bearerFormat = "API Key",
    scheme = "Bearer",
)
class OpenApiConfig(
    private val infoProperties: InfoProperties,
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

        return openApi
    }
}
