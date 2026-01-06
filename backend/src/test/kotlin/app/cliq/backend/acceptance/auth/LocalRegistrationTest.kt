package app.cliq.backend.acceptance.auth

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.auth.view.UserResponse
import app.cliq.backend.docs.EXAMPLE_EMAIL
import app.cliq.backend.docs.EXAMPLE_PASSWORD
import app.cliq.backend.docs.EXAMPLE_USERNAME
import app.cliq.backend.user.UserRepository
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals
import kotlin.test.assertNotNull
import kotlin.test.assertNull
import kotlin.test.assertTrue

@AcceptanceTest
class LocalRegistrationTest(
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
        val password = EXAMPLE_PASSWORD
        val username = EXAMPLE_USERNAME

        val registrationParams = RegistrationParams(
            email = email,
            password = password,
            username = username,
        )

        val result = mockMvc.perform(
            MockMvcRequestBuilders
                .post("/api/auth/register")
                .contentType(MediaType.APPLICATION_JSON_VALUE)
                .content(objectMapper.writeValueAsString(registrationParams)),
        )
            .andExpect(status().isCreated)
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
}
