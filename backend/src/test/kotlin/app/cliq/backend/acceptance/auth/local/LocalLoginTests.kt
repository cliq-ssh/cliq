package app.cliq.backend.acceptance.auth.local

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.auth.jwt.JwtClaims
import app.cliq.backend.auth.params.login.LoginFinishParams
import app.cliq.backend.auth.params.login.LoginStartParams
import app.cliq.backend.auth.service.SrpService
import app.cliq.backend.auth.view.login.LoginFinishResponse
import app.cliq.backend.auth.view.login.LoginStartResponse
import app.cliq.backend.config.properties.JwtProperties
import app.cliq.backend.constants.DEFAULT_EMAIL
import app.cliq.backend.constants.DEFAULT_SESSION_NAME
import app.cliq.backend.error.ErrorCode
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.support.ErrorResponseClient
import app.cliq.backend.support.UserCreationHelper
import app.cliq.backend.user.UserRepository
import com.nimbusds.srp6.BigIntegerUtils
import com.nimbusds.srp6.SRP6ClientSession
import org.junit.jupiter.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.junit.jupiter.api.assertNotNull
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.http.MediaType
import org.springframework.security.oauth2.jwt.JwtDecoder
import org.springframework.test.web.servlet.MockMvc
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders
import org.springframework.test.web.servlet.result.MockMvcResultMatchers.status
import tools.jackson.databind.ObjectMapper
import kotlin.test.assertEquals

@AcceptanceTest
class LocalLoginTests(
    @Autowired
    private val mockMvc: MockMvc,
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
    @Autowired
    private val userRepository: UserRepository,
    @Autowired
    private val srpService: SrpService,
) : AcceptanceTester() {
    @Test
    fun `test login flow`() {
        val userCreationData = userCreationHelper.createRandomUser()
        val user = userCreationData.user
        val sessionName = DEFAULT_SESSION_NAME

        val srpClientSession = SRP6ClientSession()
        srpClientSession.step1(user.email, userCreationData.password)

        val loginStartParams = LoginStartParams(user.email)
        val startResult =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/login/start")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(loginStartParams)),
                ).andExpect(status().isOk)
                .andReturn()

        val startContent = startResult.response.contentAsString
        assertNotNull(startContent)
        val startResponse = objectMapper.readValue(startContent, LoginStartResponse::class.java)

        val publicBBigInteger = BigIntegerUtils.fromHex(startResponse.publicB)
        val saltBigInteger = BigIntegerUtils.fromHex(startResponse.salt)

        val credentials =
            assertDoesNotThrow { srpClientSession.step2(srpService.params, saltBigInteger, publicBBigInteger) }

        val publicA = BigIntegerUtils.toHex(credentials.A)
        val publicM1 = BigIntegerUtils.toHex(credentials.M1)
        val loginFinishParams =
            LoginFinishParams(startResponse.authenticationSessionToken, publicA, publicM1, sessionName)

        val finishResult =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/login/finish")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(loginFinishParams)),
                ).andExpect(status().isOk)
                .andReturn()
        val finishContent = finishResult.response.contentAsString
        val finishResponse = objectMapper.readValue(finishContent, LoginFinishResponse::class.java)

        // Verify Server Response
        val step3BigInteger = BigIntegerUtils.fromHex(finishResponse.publicM2)
        assertDoesNotThrow { srpClientSession.step3(step3BigInteger) }

        // Session assertions
        val sessionResponse = finishResponse.session
        val sessionOpt = sessionRepository.findById(sessionResponse.id)
        Assertions.assertTrue(sessionOpt.isPresent)

        // Decode jwt
        val jwt = jwtDecoder.decode(sessionResponse.accessToken)
        val sub = jwt.subject
        val sid = jwt.getClaim<Long>(JwtClaims.SID)
        val issuer = jwt.getClaim<String>(JwtClaims.ISS)
        assertEquals(user.id.toString(), sub)
        assertEquals(sessionResponse.id, sid)
        assertEquals(jwtProperties.issuer, issuer.toString())
        assertNotNull(jwt.expiresAt)
        Assertions.assertTrue(jwt.expiresAt!! > jwt.issuedAt)
    }

    @Test
    fun `test invalid credentials`() {
        val sessionCount = sessionRepository.count()

        val loginStartParams = LoginStartParams(DEFAULT_EMAIL)
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/login/start")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(loginStartParams)),
            ).andExpect(status().isBadRequest)

        val loginFinishParams = LoginFinishParams("invalid_token", "0", "0")
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/login/finish")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(loginFinishParams)),
            ).andExpect(status().isBadRequest)

        val newSessionCount = sessionRepository.count()
        assertEquals(sessionCount, newSessionCount)
    }

    @Test
    fun `test unverified email cannot login`() {
        val sessionCount = sessionRepository.count()
        val creationData = userCreationHelper.createRandomUser(verified = false)
        val user = creationData.user

        val loginStartParams = LoginStartParams(user.email)

        val result =
            mockMvc
                .perform(
                    MockMvcRequestBuilders
                        .post("/api/auth/login/start")
                        .contentType(MediaType.APPLICATION_JSON_VALUE)
                        .content(objectMapper.writeValueAsString(loginStartParams)),
                ).andExpect(status().isBadRequest)
                .andReturn()

        val content = result.response.contentAsString
        val response = objectMapper.readValue(content, ErrorResponseClient::class.java)
        assertEquals(ErrorCode.EMAIL_NOT_VERIFIED, response.errorCode)

        val newSessionCount = sessionRepository.count()
        assertEquals(sessionCount, newSessionCount)
    }

    @Test
    fun `test cannot use local login when user is oidc`() {
        // Mock oidc user
        val creationData = userCreationHelper.createRandomUser()
        var user = creationData.user
        user.oidcSub = "123"
        user = userRepository.save(user)

        // Try to log in with local credentials
        val loginStartParams = LoginStartParams(user.email)
        mockMvc
            .perform(
                MockMvcRequestBuilders
                    .post("/api/auth/login/start")
                    .contentType(MediaType.APPLICATION_JSON_VALUE)
                    .content(objectMapper.writeValueAsString(loginStartParams)),
            ).andExpect(status().isForbidden)

        // Assert no session was created
        assertEquals(0, sessionRepository.count())
    }
}
