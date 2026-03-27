package app.cliq.backend.unit.utils

import app.cliq.backend.utils.CliqUrlUtils
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import java.net.URI
import kotlin.test.assertEquals

class CliqUrlUtilsTests {
    private val utils = CliqUrlUtils()

    @Test
    fun `buildOidcAppRedirectUrl builds expected redirect url`() {
        val uri = utils.buildOidcAppRedirectUrl("Token-A")
        assertEquals("cliq://oauth/callback?callbackToken=Token-A", uri.toString())
    }

    @Test
    fun `buildOidcAppRedirectUrl keeps blank exchangeCode as empty param`() {
        val uri = utils.buildOidcAppRedirectUrl("")
        assertEquals("cliq://oauth/callback?callbackToken=", uri.toString())
    }

    @Test
    fun `buildOidcAppRedirectUrl percent-encodes reserved characters in exchangeCode`() {
        val callbackToken = "a b&c=d?e/f"
        val uri = utils.buildOidcAppRedirectUrl(callbackToken)

        val uriString = uri.toString()
        assertThat(uriString).startsWith("cliq://oauth/callback?callbackToken=")
        assertThat(uriString).doesNotContain(" ")
        assertThat(uriString).contains("%")

        // Decode and reparse to verify a safe round trip
        val decodedUrl = URI.create(uriString)
        val expectedQuery = "callbackToken=$callbackToken"
        assertEquals(expectedQuery, decodedUrl.query)
    }
}
