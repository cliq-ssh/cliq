package sh.cliq.backend.acceptance.serverconfig

import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNotNull
import org.junit.jupiter.api.assertNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import sh.cliq.backend.acceptance.AcceptanceTest
import sh.cliq.backend.acceptance.AcceptanceTester
import sh.cliq.backend.config.properties.InfoProperties
import sh.cliq.backend.serverconfig.view.ServerConfigResponse
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals

@AcceptanceTest
class ServerConfigurationTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val objectMapper: ObjectMapper,
    @Autowired private val infoProperties: InfoProperties,
) : AcceptanceTester() {
    @Test
    fun `test server configuration is a public endpoint`() {
        mockMvc.get("/api/server/configuration").andExpect { status { isOk() } }
    }

    @Test
    fun `test server configuration returns expected values without oidc`() {
        val result = mockMvc.get("/api/server/configuration").andReturn()
        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val response = objectMapper.readValue(content, ServerConfigResponse::class.java)

        assertNull(response.oidcUrl)
    }

    @Test
    fun `test server configuration returns version`() {
        val result = mockMvc.get("/api/server/configuration").andReturn()
        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val response = objectMapper.readValue(content, ServerConfigResponse::class.java)

        assertNotNull(response.serverVersion)
        assertEquals(infoProperties.version, response.serverVersion)
    }
}
