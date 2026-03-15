package app.cliq.backend.utils

import org.springframework.stereotype.Service
import org.springframework.web.util.UriComponentsBuilder
import java.net.URI

@Service
class CliqUrlUtils {
    /**
     * Builds and encode the callback url that redirects the User to the App after successful OIDC authentication.
     */
    fun buildOidcAppRedirectUrl(oidcCallbackToken: String): URI =
        UriComponentsBuilder
            .fromUriString("cliq://oauth/callback")
            .queryParam("callbackToken", oidcCallbackToken)
            .build()
            .encode()
            .toUri()
}
