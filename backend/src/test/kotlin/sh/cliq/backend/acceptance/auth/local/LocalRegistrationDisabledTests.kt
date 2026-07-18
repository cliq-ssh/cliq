package sh.cliq.backend.acceptance.auth.local

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNotNull
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.context.TestPropertySource
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import sh.cliq.backend.acceptance.AcceptanceTest
import sh.cliq.backend.acceptance.AcceptanceTester
import sh.cliq.backend.auth.params.RegistrationParams
import sh.cliq.backend.constants.DEFAULT_DATA_ENCRYPTION_KEY
import sh.cliq.backend.constants.DEFAULT_SRP_SALT
import sh.cliq.backend.constants.DEFAULT_SRP_VERIFIER
import sh.cliq.backend.constants.EXAMPLE_EMAIL
import sh.cliq.backend.constants.EXAMPLE_USERNAME
import sh.cliq.backend.error.ErrorCode
import sh.cliq.backend.support.ErrorResponseClient
import sh.cliq.backend.user.UserRepository
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
