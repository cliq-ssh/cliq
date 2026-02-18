package app.cliq.backend.unit.serverconfig

import app.cliq.backend.config.properties.AuthProperties
import app.cliq.backend.config.properties.InfoProperties
import app.cliq.backend.serverconfig.factory.ServerConfigResponseFactory
import app.cliq.backend.utils.FeatureUtils
import org.junit.jupiter.api.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertTrue

class ServerConfigResponseFactoryTests {
    private val featureUtils: FeatureUtils = mock()
    private val infoProperties =
        InfoProperties(
            name = "cliq-backend",
            version = "1.2.3",
            description = "Backend for cliq",
        )

    private val authProperties =
        AuthProperties(
            local =
                AuthProperties.LocalAuthProperties(
                    registration = true,
                    login = false,
                ),
            oidc = mock(),
        )

    private val factory =
        ServerConfigResponseFactory(
            featureUtils = featureUtils,
            infoProperties = infoProperties,
            authProperties = authProperties,
        )

    @Test
    fun `factory exposes local auth properties in response`() {
        whenever(featureUtils.isProfileActive(org.mockito.kotlin.any())).thenReturn(false)

        val response = factory.getResponse()

        assertEquals("1.2.3", response.serverVersion)
        assertEquals(true, response.localAuthProperties.registration)
        assertEquals(false, response.localAuthProperties.login)
        assertFalse(response.localAuthProperties.login)
        assertTrue(response.localAuthProperties.registration)
    }
}
