package app.cliq.backend.config.oidc

import org.slf4j.LoggerFactory
import tools.jackson.databind.ObjectMapper
import java.net.URI
import java.net.http.HttpClient
import java.net.http.HttpRequest
import java.net.http.HttpResponse

/**
 * Resolve OIDC URLs (authorization endpoint and token endpoint) using OIDC discovery.
 */
class OidcUrlResolver(
    private val oidcProperties: OidcProperties,
    private val objectMapper: ObjectMapper,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)

    private val cachedUrls = resolveOidcUrls()

    fun getAuthUrl(): String = cachedUrls.first

    fun getTokenUrl(): String = cachedUrls.second

    private fun resolveOidcUrls(): Pair<String, String> {
        val issuer = oidcProperties.issuerUri ?: throw IllegalStateException("OIDC issuer URI is not configured")
        val issuerUrl = issuer.trimEnd('/')
        val wellKnownUrl = "$issuerUrl/.well-known/openid-configuration"

        val webClient = HttpClient.newHttpClient()
        val request =
            HttpRequest
                .newBuilder()
                .GET()
                .uri(URI.create(wellKnownUrl))
                .build()

        val discovery: Map<*, *>? =
            try {
                val response = webClient.send(request, HttpResponse.BodyHandlers.ofString())
                if (response.statusCode() == 200) {
                    objectMapper.readValue(response.body(), Map::class.java)
                } else {
                    null
                }
            } catch (e: Exception) {
                logger.error("Error while processing request", e)

                throw e
            }

        val authUrl =
            discovery?.get("authorization_endpoint") as? String
                ?: throw IllegalStateException("Authorization endpoint not found in OIDC discovery")
        val tokenUrl =
            discovery["token_endpoint"] as? String
                ?: throw IllegalStateException("Token endpoint not found in OIDC discovery")

        return Pair(authUrl, tokenUrl)
    }
}
