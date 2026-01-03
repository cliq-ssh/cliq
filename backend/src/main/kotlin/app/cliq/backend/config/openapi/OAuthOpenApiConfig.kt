package app.cliq.backend.config.openapi

import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.Operation
import io.swagger.v3.oas.models.PathItem
import io.swagger.v3.oas.models.responses.ApiResponse
import io.swagger.v3.oas.models.responses.ApiResponses
import org.springdoc.core.customizers.OpenApiCustomizer
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class OAuthOpenApiConfig {
    @Bean
    fun oauthAuthorizationEndpoint(): OpenApiCustomizer =
        OpenApiCustomizer { openApi: OpenAPI ->
            val operation =
                Operation()
                    .summary("Initiate OAuth2 authorization")
                    .description("Redirects the user to the configured OIDC provider for authentication.")
                    .responses(
                        ApiResponses()
                            .addApiResponse(
                                "302",
                                ApiResponse()
                                    .description("Redirect to OAuth2 provider"),
                            ).addApiResponse(
                                "404",
                                ApiResponse()
                                    .description("OAuth2 has been disabled"),
                            ),
                    ).addTagsItem("Authentication")

            val pathItem =
                PathItem()
                    .get(operation)

            openApi.paths.addPathItem("/oauth2/authorization/oidc", pathItem)
        }

    @Bean
    fun oauthBackChannelLogoutEndpoint(): OpenApiCustomizer =
        OpenApiCustomizer { openApi: OpenAPI ->
            val operation =
                Operation()
                    .summary("OIDC Back-Channel Logout Endpoint")
                    .description("Handles back-channel logout requests from the OIDC provider.")
                    .responses(
                        ApiResponses()
                            .addApiResponse(
                                "200",
                                ApiResponse()
                                    .description("Logout successful"),
                            ).addApiResponse(
                                "400",
                                ApiResponse()
                                    .description("Invalid logout request"),
                            ).addApiResponse(
                                "404",
                                ApiResponse()
                                    .description("OIDC has been disabled"),
                            ),
                    ).addTagsItem("Authentication")

            val pathItem =
                PathItem()
                    .post(operation)

            openApi.paths.addPathItem("/logout/connect/back-channel/oidc", pathItem)
        }
}
