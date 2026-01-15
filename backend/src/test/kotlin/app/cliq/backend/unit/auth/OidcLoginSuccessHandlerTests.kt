package app.cliq.backend.unit.auth

import app.cliq.backend.auth.jwt.JwtClaims
import app.cliq.backend.auth.jwt.TokenPair
import app.cliq.backend.auth.service.JwtService
import app.cliq.backend.auth.service.RefreshTokenService
import app.cliq.backend.config.security.oidc.OidcLoginSuccessHandler
import app.cliq.backend.session.Session
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.user.User
import app.cliq.backend.user.service.UserOidcService
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.never
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.springframework.mock.web.MockHttpServletRequest
import org.springframework.mock.web.MockHttpServletResponse
import org.springframework.security.core.Authentication
import org.springframework.security.oauth2.core.oidc.OidcIdToken
import org.springframework.security.oauth2.core.oidc.user.DefaultOidcUser
import org.springframework.security.oauth2.core.oidc.user.OidcUser
import org.springframework.security.oauth2.jwt.Jwt
import java.time.Instant
import java.util.UUID

class OidcLoginSuccessHandlerTests {
    private val userOidcService: UserOidcService = mock()
    private val jwtService: JwtService = mock()
    private val refreshTokenService: RefreshTokenService = mock()
    private val sessionRepository: SessionRepository = mock()

    private val handler =
        OidcLoginSuccessHandler(
            userOidcService = userOidcService,
            jwtService = jwtService,
            refreshTokenService = refreshTokenService,
            sessionRepository = sessionRepository,
        )

    @Test
    fun `redirects with generated token pair when no existing session`() {
        val sid = "sid-123"
        val oidcUser = oidcUserWithSid(sid)
        val authentication = authenticationWithPrincipal(oidcUser)

        val user: User = mock()
        whenever(userOidcService.putUserFromJwt(eq(oidcUser))).thenReturn(user)

        whenever(sessionRepository.findByOidcSessionId(eq(sid))).thenReturn(null)

        val jwt: Jwt = mock()
        whenever(jwt.tokenValue).thenReturn("access-A")
        val tokenPair =
            TokenPair(
                jwt = jwt,
                refreshToken = "refresh-A",
                session = mock(),
            )
        whenever(jwtService.generateOidcJwtTokenPair(eq(user), eq(sid))).thenReturn(tokenPair)

        val request: HttpServletRequest = MockHttpServletRequest()
        val response: HttpServletResponse = MockHttpServletResponse()

        handler.onAuthenticationSuccess(request, response, authentication)

        val redirectedUrl = (response as MockHttpServletResponse).redirectedUrl
        assertEquals(
            "cliq://oauth/callback?jwtAccessToken=access-A&refreshToken=refresh-A",
            redirectedUrl,
        )

        verify(sessionRepository).findByOidcSessionId(eq(sid))
        verify(jwtService).generateOidcJwtTokenPair(eq(user), eq(sid))
        verify(refreshTokenService, never()).rotate(any())
    }

    @Test
    fun `redirects with rotated token pair when existing session present`() {
        val sid = "sid-456"
        val oidcUser = oidcUserWithSid(sid)
        val authentication = authenticationWithPrincipal(oidcUser)

        val user: User = mock()
        whenever(userOidcService.putUserFromJwt(eq(oidcUser))).thenReturn(user)

        val existingSession: Session = mock()
        whenever(sessionRepository.findByOidcSessionId(eq(sid))).thenReturn(existingSession)

        val jwt: Jwt = mock()
        whenever(jwt.tokenValue).thenReturn("access-B")
        val rotated = TokenPair(jwt = jwt, refreshToken = "refresh-B", session = mock())
        whenever(refreshTokenService.rotate(eq(existingSession))).thenReturn(rotated)

        val request: HttpServletRequest = MockHttpServletRequest()
        val response: HttpServletResponse = MockHttpServletResponse()

        handler.onAuthenticationSuccess(request, response, authentication)

        val redirectedUrl = (response as MockHttpServletResponse).redirectedUrl
        assertEquals(
            "cliq://oauth/callback?jwtAccessToken=access-B&refreshToken=refresh-B",
            redirectedUrl,
        )

        verify(sessionRepository).findByOidcSessionId(eq(sid))
        verify(refreshTokenService).rotate(eq(existingSession))
        verify(jwtService, never()).generateOidcJwtTokenPair(any(), any())
    }

    private fun authenticationWithPrincipal(oidcUser: OidcUser): Authentication {
        val authentication: Authentication = mock()
        whenever(authentication.principal).thenReturn(oidcUser)
        return authentication
    }

    private fun oidcUserWithSid(sid: String): OidcUser {
        val now = Instant.now()
        val claims =
            mapOf(
                "sub" to UUID.randomUUID().toString(),
                JwtClaims.SID to sid,
            )
        val idToken = OidcIdToken("id-token", now.minusSeconds(5), now.plusSeconds(300), claims)
        return DefaultOidcUser(emptyList(), idToken)
    }
}
