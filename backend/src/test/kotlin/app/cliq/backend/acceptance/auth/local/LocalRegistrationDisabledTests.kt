package app.cliq.backend.acceptance.auth.local

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.constants.DEFAULT_DATA_ENCRYPTION_KEY
import app.cliq.backend.constants.DEFAULT_SRP_SALT
import app.cliq.backend.constants.DEFAULT_SRP_VERIFIER
import app.cliq.backend.constants.EXAMPLE_EMAIL
import app.cliq.backend.constants.EXAMPLE_USERNAME
import app.cliq.backend.error.ErrorCode
import app.cliq.backend.support.ErrorResponseClient
import app.cliq.backend.user.UserRepository
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.context.TestPropertySource
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper

@AcceptanceTest
@TestPropertySource(properties = ["app.auth.local.registration=false"])
class LocalRegistrationDisabledTests(
    @Autowired private val mockMvc: MockMvc,
    @Autowired private val userRepository: UserRepository,
    @Autowired private val objectMapper: ObjectMapper,
) : AcceptanceTester() {
    @Test
    fun `test registration endpoint is not available`() {
        val userCount = userRepository.count()

        val registrationParams =
            RegistrationParams(
                EXAMPLE_EMAIL,
                EXAMPLE_USERNAME,
                DEFAULT_DATA_ENCRYPTION_KEY,
                DEFAULT_SRP_SALT,
                DEFAULT_SRP_VERIFIER,
            )
        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/register")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(registrationParams)),
                ).andExpect(status().isForbidden)
                .andReturn()

        val content = result.response.contentAsString
        assertNotNull(content)
        val errorResponse = objectMapper.readValue(content, ErrorResponseClient::class.java)

        assertEquals(ErrorCode.LOCAL_REGISTRATION_DISABLED, errorResponse.errorCode)

        val newUserCount = userRepository.count()
        assertEquals(userCount, newUserCount)
    }
}
