package app.cliq.backend.acceptance.auth

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.jwt.JwtClaims
import app.cliq.backend.auth.params.LoginParams
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.config.properties.JwtProperties
import app.cliq.backend.docs.EXAMPLE_EMAIL
import app.cliq.backend.docs.EXAMPLE_PASSWORD
import app.cliq.backend.docs.EXAMPLE_USERNAME
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.user.factory.UserFactory
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNotNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals

/*
TODO:
    - Test invalid credentials
    - Test unverified email login
 */
@AcceptanceTest
class LocalLoginTest(
    @Autowired
    private val mockMvc: MockMvc,
    @Autowired
    private val userFactory: UserFactory,
    @Autowired
    private val objectMapper: ObjectMapper,
    @Autowired
    private val sessionRepository: SessionRepository,
    @Autowired
    private val jwtDecoder: JwtDecoder,
    @Autowired
    private val jwtProperties: JwtProperties,
) : AcceptanceTester() {
    @Test
    fun `test login flow`() {
        val registrationParams =
            RegistrationParams(
                email = EXAMPLE_EMAIL,
                password = EXAMPLE_PASSWORD,
                username = EXAMPLE_USERNAME,
            )
        val user = userFactory.createFromRegistrationParams(registrationParams)

        val sessionName = "Test session"
        val loginParams =
            LoginParams(
                email = EXAMPLE_EMAIL,
                password = EXAMPLE_PASSWORD,
                name = sessionName,
            )

        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(loginParams)),
                ).andExpect(status().isOk)
                .andReturn()

        // Response assertions
        assertEquals(MediaType.APPLICATION_JSON_VALUE, result.response.contentType)
        val content = result.response.contentAsString
        val response = objectMapper.readValue(content, TokenResponse::class.java)
        assertEquals(sessionName, response.name)

        // Session assertions
        val sessionOpt = sessionRepository.findById(response.id)
        assertTrue(sessionOpt.isPresent)

        // Decode jwt
        val jwt = jwtDecoder.decode(response.accessToken)
        val sub = jwt.subject
        val sid = jwt.getClaim<Long>(JwtClaims.SID)
        val issuer = jwt.getClaim<String>(JwtClaims.ISS)
        assertEquals(user.id.toString(), sub)
        assertEquals(response.id, sid)
        assertEquals(jwtProperties.issuer, issuer.toString())
        assertNotNull(jwt.expiresAt)
        assertTrue(jwt.expiresAt!! > jwt.issuedAt)
    }
}
