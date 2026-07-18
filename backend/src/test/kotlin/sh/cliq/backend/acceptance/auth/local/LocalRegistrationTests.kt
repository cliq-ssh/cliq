package sh.cliq.backend.acceptance.auth.local

import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers
import sh.cliq.backend.acceptance.AcceptanceTest
import sh.cliq.backend.acceptance.AcceptanceTester
import sh.cliq.backend.auth.params.RegistrationParams
import sh.cliq.backend.constants.DEFAULT_DATA_ENCRYPTION_KEY
import sh.cliq.backend.constants.DEFAULT_SRP_SALT
import sh.cliq.backend.constants.DEFAULT_SRP_VERIFIER
import sh.cliq.backend.constants.EXAMPLE_EMAIL
import sh.cliq.backend.constants.EXAMPLE_USERNAME
import sh.cliq.backend.user.UserRepository
import sh.cliq.backend.user.view.UserResponse
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

@AcceptanceTest
class LocalRegistrationTests(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val userRepository: UserRepository,
) : AcceptanceTester() {
    @Test
    fun `test normal registration flow`() {
        val email = EXAMPLE_EMAIL
        val username = EXAMPLE_USERNAME

        val registrationParams =
            RegistrationParams(
                email = email,
                username = username,
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
                ).andExpect(MockMvcResultMatchers.status().isCreated)
                .andReturn()

        // Response assertions
        assertEquals(MediaType.APPLICATION_JSON_VALUE, result.response.contentType)
        val content = result.response.contentAsString
        val response = objectMapper.readValue(content, UserResponse::class.java)
        assertEquals(email, response.email)
        assertEquals(username, response.username)

        // User assertions
        val userOpt = userRepository.findById(response.id)
        assertTrue(userOpt.isPresent)
        val user = userOpt.get()

        assertEquals(email, user.email)
        assertEquals(username, user.name)
        assertNull(user.emailVerificationToken)
        assertNull(user.emailVerificationSentAt)
        assertNotNull(user.emailVerifiedAt)

        assertTrue(user.isEmailVerified())
    }

    @Test
    fun `test registration with existing email`() {
        val email = EXAMPLE_EMAIL
        val username = EXAMPLE_USERNAME

        val registrationParams =
            RegistrationParams(
                email = email,
                username = username,
                DEFAULT_DATA_ENCRYPTION_KEY,
                DEFAULT_SRP_SALT,
                DEFAULT_SRP_VERIFIER,
            )

        // First registration should succeed
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/register")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(registrationParams)),
            ).andExpect(MockMvcResultMatchers.status().isCreated)

        // Second registration with the same email should fail
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/register")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(registrationParams)),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)
    }
}
