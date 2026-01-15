package app.cliq.backend.acceptance.auth.local

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.params.LoginParams
import app.cliq.backend.error.ErrorCode
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.support.ErrorResponseClient
import app.cliq.backend.support.UserCreationHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNotNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.context.TestPropertySource
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals

@AcceptanceTest
@TestPropertySource(properties = ["app.auth.local.login=false"])
class LocalLoginDisabledTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userCreationHelper: UserCreationHelper,
    @Autowired private val sessionRepository: SessionRepository,
    @Autowired private val objectMapper: ObjectMapper,
) : AcceptanceTester() {
    @Test
    fun `test login endpoint is not available`() {
        val sessionCount = sessionRepository.count()
        assertEquals(0, sessionCount)

        val creationData = userCreationHelper.createRandomUser()
        val user = creationData.user

        val loginParams = LoginParams(user.email, creationData.password)
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(loginParams)),
                ).andExpect(MockMvcResultMatchers.status().isForbidden)
                .andReturn()

        val content = result.response.contentAsString
        assertNotNull(content)
        val errorResponse = objectMapper.readValue(content, ErrorResponseClient::class.java)

        assertEquals(ErrorCode.LOCAL_LOGIN_DISABLED, errorResponse.errorCode)

        val newSessionCount = sessionRepository.count()
        assertEquals(sessionCount, newSessionCount)
    }
}
