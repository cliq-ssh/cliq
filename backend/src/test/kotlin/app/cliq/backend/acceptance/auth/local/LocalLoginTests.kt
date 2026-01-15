package app.cliq.backend.acceptance.auth.local

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.jwt.JwtClaims
import app.cliq.backend.auth.params.LoginParams
import app.cliq.backend.auth.params.RegistrationParams
import app.cliq.backend.auth.view.TokenResponse
import app.cliq.backend.config.properties.JwtProperties
import app.cliq.backend.constants.EXAMPLE_EMAIL
import app.cliq.backend.constants.EXAMPLE_PASSWORD
import app.cliq.backend.constants.EXAMPLE_USERNAME
import app.cliq.backend.error.ErrorCode
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.support.ErrorResponseClient
import app.cliq.backend.support.UserCreationHelper
import app.cliq.backend.user.factory.UserFactory
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNotNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals

@AcceptanceTest
class LocalLoginTests(
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
    @Autowired
    private val userCreationHelper: UserCreationHelper,
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
                ).andExpect(MockMvcResultMatchers.status().isOk)
                .andReturn()

        // Response assertions
        assertEquals(MediaType.APPLICATION_JSON_VALUE, result.response.contentType)
        val content = result.response.contentAsString
        val response = objectMapper.readValue(content, TokenResponse::class.java)
        assertEquals(sessionName, response.name)

        // Session assertions
        val sessionOpt = sessionRepository.findById(response.id)
        Assertions.assertTrue(sessionOpt.isPresent)

        // Decode jwt
        val jwt = jwtDecoder.decode(response.accessToken)
        val sub = jwt.subject
        val sid = jwt.getClaim<Long>(JwtClaims.SID)
        val issuer = jwt.getClaim<String>(JwtClaims.ISS)
        assertEquals(user.id.toString(), sub)
        assertEquals(response.id, sid)
        assertEquals(jwtProperties.issuer, issuer.toString())
        assertNotNull(jwt.expiresAt)
        Assertions.assertTrue(jwt.expiresAt!! > jwt.issuedAt)
    }

    @Test
    fun `test invalid credentials`() {
        val sessionCount = sessionRepository.count()

        val loginParams = LoginParams(EXAMPLE_EMAIL, "invalidPassword")

        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/login")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(loginParams)),
            ).andExpect(MockMvcResultMatchers.status().isBadRequest)

        val newSessionCount = sessionRepository.count()
        assertEquals(sessionCount, newSessionCount)
    }

    @Test
    fun `test unverified email cannot login`() {
        val sessionCount = sessionRepository.count()
        val creationData = userCreationHelper.createRandomUser(verified = false)
        val user = creationData.user
        val loginParams = LoginParams(user.email, creationData.password)

        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/login")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(loginParams)),
                ).andExpect(MockMvcResultMatchers.status().isBadRequest)
                .andReturn()

        val content = result.response.contentAsString
        val response = objectMapper.readValue(content, ErrorResponseClient::class.java)
        assertEquals(ErrorCode.EMAIL_NOT_VERIFIED, response.errorCode)

        val newSessionCount = sessionRepository.count()
        assertEquals(sessionCount, newSessionCount)
    }
}
