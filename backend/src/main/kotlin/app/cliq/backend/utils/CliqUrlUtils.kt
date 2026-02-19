package app.cliq.backend.utils

import org.springframework.stereotype.Service
import org.springframework.web.util.UriComponentsBuilder
import java.net.URI

@Service
class CliqUrlUtils {
    /**
     * Builds and encode the callback url that redirects the User to the App after successfull OIDC authentication.
     */
    fun buildOidcAppRedirectUrl(exchangeCode: String): URI =
        UriComponentsBuilder
            .fromUriString("cliq://oauth/callback")
            .queryParam("exchangeCode", exchangeCode)
            .build()
            .encode()
            .toUri()
}
