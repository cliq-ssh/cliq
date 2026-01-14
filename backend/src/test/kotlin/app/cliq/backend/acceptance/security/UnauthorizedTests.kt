package app.cliq.backend.acceptance.security

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.error.ErrorCode
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals

@AcceptanceTest
class UnauthorizedTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val objectMapper: ObjectMapper,
) : AcceptanceTester() {
    data class ErrorResponseClient(
        val errorCode: ErrorCode,
        val details: Any? = null,
    )

    @Test
    fun `test correct unauthorized response`() {
        val result =
            mockMvc
                .perform(MockMvcRequestBuilders.get("/api/private"))
                .andExpect(status().isUnauthorized)
                .andReturn()

        val content = result.response.contentAsString
        assert(content.isNotEmpty())

        val errorResponse = objectMapper.readValue(content, ErrorResponseClient::class.java)
        val errorCode = errorResponse.errorCode
        assertEquals(ErrorCode.MISSING_AUTHENTICATION_TOKEN, errorCode)
    }
}
