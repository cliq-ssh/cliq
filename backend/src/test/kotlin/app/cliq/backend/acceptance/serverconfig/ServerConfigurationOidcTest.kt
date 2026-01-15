package app.cliq.backend.acceptance.serverconfig

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.constants.Features
import app.cliq.backend.constants.Oidc
import app.cliq.backend.serverconfig.view.ServerConfigResponse
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.context.ActiveProfiles
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals

@AcceptanceTest
@ActiveProfiles(Features.OIDC)
class ServerConfigurationOidcTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val objectMapper: ObjectMapper,
) : AcceptanceTester() {
    @Test
    fun `test server configuration returns expected values with oidc`() {
        val result = mockMvc.get("/api/server/configuration").andReturn()
        val content = result.response.contentAsString
        assert(content.isNotEmpty())
        val response = objectMapper.readValue(content, ServerConfigResponse::class.java)

        assertEquals(Oidc.AUTHORIZATION_ENDPOINT, response.oidcUrl)
    }
}
