package app.cliq.backend.config.openapi

import app.cliq.backend.constants.Oidc
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

            openApi.paths.addPathItem(Oidc.AUTHORIZATION_ENDPOINT, pathItem)
        }

    @Bean
    fun oauthCallbackEndpoint(): OpenApiCustomizer =
        OpenApiCustomizer { openApi: OpenAPI ->
            val operation =
                Operation()
                    .summary("OAuth2 callback endpoint")
                    .description("Handles the callback from the OIDC provider after authentication.")
                    .responses(
                        ApiResponses()
                            .addApiResponse(
                                "302",
                                ApiResponse()
                                    .description("Redirect to the app."),
                            ).addApiResponse(
                                "404",
                                ApiResponse()
                                    .description("OAuth2 has been disabled"),
                            ),
                    ).addTagsItem("Authentication")

            val pathItem =
                PathItem()
                    .get(operation)

            openApi.paths.addPathItem(Oidc.CALLBACK_ENDPOINT, pathItem)
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

            openApi.paths.addPathItem(Oidc.BACK_CHANNEL_LOGOUT_ENDPOINT, pathItem)
        }
}
