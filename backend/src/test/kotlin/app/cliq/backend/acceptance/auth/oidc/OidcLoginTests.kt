package app.cliq.backend.acceptance.auth.oidc

import app.cliq.backend.acceptance.OidcAcceptanceTest
import app.cliq.backend.acceptance.OidcAcceptanceTester
import app.cliq.backend.docs.EXAMPLE_EMAIL
import app.cliq.backend.docs.EXAMPLE_PASSWORD
import app.cliq.backend.support.keycloak.KeycloakManager
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Disabled
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.HttpHeaders
import org.springframework.http.MediaType
import org.springframework.test.web.reactive.server.WebTestClient
import org.springframework.test.web.reactive.server.returnResult
import java.net.URI

@OidcAcceptanceTest
class OidcLoginTests(
    @Autowired private val keycloakManager: KeycloakManager,
    @Autowired private val webTestClient: WebTestClient,
) : OidcAcceptanceTester() {
    @Test
    @Disabled
    fun `test login with oidc`() {
        val username = EXAMPLE_EMAIL
        val password = EXAMPLE_PASSWORD
        keycloakManager.createUser(username, password)

        // Start OIDC login: /oauth2/authorization/oidc
        val authRedirectLocation =
            webTestClient
                .get()
                .uri("/oauth2/authorization/oidc")
                .exchange()
                .expectStatus()
                .is3xxRedirection
                .returnResult<String>()
                .responseHeaders
                .location

        assertThat(authRedirectLocation).isNotNull
        val keycloakLoginUri = authRedirectLocation!!

        // Simulate submitting the Keycloak login form
        // Typical Keycloak params: username, password, credentialId, etc.
        val loginResponse =
            webTestClient
                .post()
                .uri(keycloakLoginUri)
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .bodyValue(
                    "username=$username&password=$password",
                ).exchange()
                .expectStatus()
                .is3xxRedirection
                .returnResult<String>()

        // Follow redirect back to our app (callback)
        val callbackLocation: URI? =
            loginResponse
                .responseHeaders
                .location

        assertThat(callbackLocation).isNotNull

        val finalResponse =
            webTestClient
                .get()
                .uri(callbackLocation!!)
                .exchange()
                .expectStatus()
                .is3xxRedirection // usually redirected to a landing page
                .returnResult<String>()

        // 4\) Extract session cookie from final response
        val setCookieHeaders = finalResponse.responseHeaders[HttpHeaders.SET_COOKIE].orEmpty()
        assertThat(setCookieHeaders).isNotEmpty

        val sessionCookie =
            setCookieHeaders
                .first { it.startsWith("JSESSIONID") } // or your session cookie name

        // 5\) Use the authenticated session to access a secured endpoint
        webTestClient
            .get()
            .uri("/api/me") // example secured endpoint
            .header(HttpHeaders.COOKIE, sessionCookie)
            .exchange()
            .expectStatus()
            .isOk
    }
}
