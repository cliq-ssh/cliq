package app.cliq.backend.unit.auth

import app.cliq.backend.auth.factory.OidcCallbackTokenFactory
import app.cliq.backend.auth.jwt.JwtClaims
import app.cliq.backend.auth.oidc.OidcCallbackToken
import app.cliq.backend.config.security.oidc.OidcLoginSuccessHandler
import app.cliq.backend.user.User
import app.cliq.backend.user.service.UserOidcService
import app.cliq.backend.utils.CliqUrlUtils
import jakarta.servlet.http.HttpServletRequest
import jakarta.servlet.http.HttpServletResponse
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test
import org.mockito.kotlin.any
import org.mockito.kotlin.argumentCaptor
import org.mockito.kotlin.eq
import org.mockito.kotlin.mock
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.springframework.security.core.Authentication
import org.springframework.security.oauth2.core.oidc.OidcIdToken
import org.springframework.security.oauth2.core.oidc.user.DefaultOidcUser
import org.springframework.security.oauth2.core.oidc.user.OidcUser
import java.time.Instant
import java.util.UUID

class OidcLoginSuccessHandlerTests {
    private val userOidcService: UserOidcService = mock()
    private val oidcCallbackTokenFactory: OidcCallbackTokenFactory = mock()

    private val handler =
        OidcLoginSuccessHandler(
            userOidcService = userOidcService,
            cliqUrlUtils = CliqUrlUtils(),
            oidcCallbackTokenFactory = oidcCallbackTokenFactory,
        )

    @Test
    fun `redirects with generated token pair when no existing session`() {
        val sid = "sid-123"
        val callbackTokenString = "Token-A"
        val oidcUser = oidcUserWithSid(sid)
        val authentication = authenticationWithPrincipal(oidcUser)

        val user: User = mock()
        whenever(userOidcService.putUserFromOidcUser(eq(oidcUser))).thenReturn(user)

        val oidcCallbackToken: OidcCallbackToken = mock()
        whenever(oidcCallbackToken.token).thenReturn(callbackTokenString)

        whenever(
            oidcCallbackTokenFactory.createFromRequestAndUser(any(), eq(user), eq(sid)),
        ).thenReturn(oidcCallbackToken)

        val request: HttpServletRequest = mock()
        val response: HttpServletResponse = mock()

        handler.onAuthenticationSuccess(request, response, authentication)

        val redirectCaptor = argumentCaptor<String>()
        verify(response).sendRedirect(redirectCaptor.capture())
        assertEquals(
            "cliq://oauth/callback?callbackToken=$callbackTokenString",
            redirectCaptor.firstValue,
        )
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
