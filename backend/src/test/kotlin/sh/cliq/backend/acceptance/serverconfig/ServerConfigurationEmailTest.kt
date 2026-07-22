package sh.cliq.backend.acceptance.serverconfig

import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.get
import sh.cliq.backend.acceptance.EmailAcceptanceTest
import sh.cliq.backend.acceptance.EmailAcceptanceTester
import sh.cliq.backend.serverconfig.view.ServerConfigResponse
import tools.jackson.databind.ObjectMapper

@EmailAcceptanceTest
class ServerConfigurationEmailTest(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val objectMapper: ObjectMapper,
) : EmailAcceptanceTester() {
    @Test
    fun `test server configuration returns expected values with email enabled`() {
        val result = mockMvc.get("/api/server/configuration").andReturn()
        val content = result.response.contentAsString
        assertTrue(content.isNotEmpty())
        val response = objectMapper.readValue(content, ServerConfigResponse::class.java)

        assertTrue(response.emailEnabled)
    }
}
