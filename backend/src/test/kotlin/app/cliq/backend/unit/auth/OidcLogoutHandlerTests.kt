package app.cliq.backend.unit.auth

import app.cliq.backend.config.security.oidc.OidcLogoutHandler
import app.cliq.backend.session.SessionRepository
import app.cliq.backend.user.User
import app.cliq.backend.user.UserRepository
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.junit.jupiter.api.Test
import org.mockito.kotlin.any
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.never
import org.mockito.kotlin.verify
import org.mockito.kotlin.verifyNoInteractions
import org.mockito.kotlin.whenever
import org.springframework.mock.web.MockHttpServletRequest
import org.springframework.mock.web.MockHttpServletResponse
import org.springframework.security.core.Authentication
import org.springframework.security.oauth2.client.oidc.authentication.logout.OidcLogoutToken

class OidcLogoutHandlerTests {
    private val sessionRepository: SessionRepository = mock()
    private val userRepository: UserRepository = mock()

    private val handler =
        OidcLogoutHandler(
            sessionRepository = sessionRepository,
            userRepository = userRepository,
        )

    @Test
    fun `logout returns early when authentication is null`() {
        val request: HttpServletRequest = MockHttpServletRequest()
        val response: HttpServletResponse = MockHttpServletResponse()

        handler.logout(request, response, null)

        verifyNoInteractions(sessionRepository, userRepository)
    }

    @Test
    fun `logout deletes by oidc session id when token has sessionId`() {
        val sessionId = "sid-123"
        val sub = "sub-abc"

        val token: OidcLogoutToken = mock()
        whenever(token.sessionId).thenReturn(sessionId)
        whenever(token.subject).thenReturn(sub)

        val authentication: Authentication = mock()
        whenever(authentication.principal).thenReturn(token)

        whenever(sessionRepository.deleteByOidcSessionId(eq(sessionId))).thenReturn(2)

        val request: HttpServletRequest = MockHttpServletRequest()
        val response: HttpServletResponse = MockHttpServletResponse()

        handler.logout(request, response, authentication)

        verify(sessionRepository).deleteByOidcSessionId(eq(sessionId))
        verify(sessionRepository, never()).deleteAllByUserId(any())
        verifyNoInteractions(userRepository)
    }

    @Test
    fun `logout deletes by oidc subject when token sessionId is null and user exists`() {
        val sub = "sub-xyz"

        val token: OidcLogoutToken = mock()
        whenever(token.sessionId).thenReturn(null)
        whenever(token.subject).thenReturn(sub)

        val authentication: Authentication = mock()
        whenever(authentication.principal).thenReturn(token)

        val user: User = mock()
        whenever(user.id).thenReturn(42L)
        whenever(userRepository.findByOidcSub(eq(sub))).thenReturn(user)

        whenever(sessionRepository.deleteAllByUserId(eq(42L))).thenReturn(3)

        val request: HttpServletRequest = MockHttpServletRequest()
        val response: HttpServletResponse = MockHttpServletResponse()

        handler.logout(request, response, authentication)

        verify(userRepository).findByOidcSub(eq(sub))
        verify(sessionRepository).deleteAllByUserId(eq(42L))
        verify(sessionRepository, never()).deleteByOidcSessionId(any())
    }

    @Test
    fun `logout does nothing when token sessionId is null and user does not exist`() {
        val sub = "sub-missing"

        val token: OidcLogoutToken = mock()
        whenever(token.sessionId).thenReturn(null)
        whenever(token.subject).thenReturn(sub)

        val authentication: Authentication = mock()
        whenever(authentication.principal).thenReturn(token)

        whenever(userRepository.findByOidcSub(eq(sub))).thenReturn(null)

        val request: HttpServletRequest = MockHttpServletRequest()
        val response: HttpServletResponse = MockHttpServletResponse()

        handler.logout(request, response, authentication)

        verify(userRepository).findByOidcSub(eq(sub))
        verifyNoInteractions(sessionRepository)
    }
}
