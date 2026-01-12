package app.cliq.backend.unit.user.oidc

import app.cliq.backend.docs.EXAMPLE_EMAIL
import app.cliq.backend.docs.EXAMPLE_USERNAME
import app.cliq.backend.unit.user.AbstractUserTests
import app.cliq.backend.user.UserRepository
import app.cliq.backend.user.factory.UserFactory
import app.cliq.backend.user.service.UserOidcService
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.BDDMockito.given
import org.mockito.Mockito.verify
import org.mockito.junit.jupiter.MockitoExtension
import org.mockito.kotlin.any
import org.mockito.kotlin.mock
import org.mockito.kotlin.times
import org.springframework.security.oauth2.core.oidc.user.OidcUser
import kotlin.test.assertEquals
import kotlin.test.assertSame

const val OIDC_SUB = "sub-123"
const val NON_EXISTENT_EMAIL = "unknown.$EXAMPLE_EMAIL"

@ExtendWith(MockitoExtension::class)
class UserOidcServiceTests : AbstractUserTests() {
    private lateinit var userRepository: UserRepository
    private lateinit var userFactory: UserFactory
    private lateinit var classUnderTest: UserOidcService

    @BeforeEach
    fun setUp() {
        userRepository = mock()
        userFactory = mock()
        classUnderTest = UserOidcService(userRepository, userFactory)
    }

    private fun mockOidcUser(
        sub: String = OIDC_SUB,
        email: String = EXAMPLE_EMAIL,
        preferredUsername: String = EXAMPLE_USERNAME,
        mockEmail: Boolean = true,
        mockPreferredUsername: Boolean = true,
    ): OidcUser {
        val oidcUser = mock<OidcUser>()
        given(oidcUser.subject).willReturn(sub)
        if (mockEmail) {
            given(oidcUser.email).willReturn(email)
        }
        if (mockPreferredUsername) {
            given(oidcUser.preferredUsername).willReturn(preferredUsername)
        }

        return oidcUser
    }

    @Test
    fun `returns already mapped user when oidcSub is linked`() {
        val oidcUser = mockOidcUser(mockEmail = false, mockPreferredUsername = false)
        val existingUser = createTestUser().apply { oidcSub = OIDC_SUB }

        given(userRepository.findByOidcSub(OIDC_SUB)).willReturn(existingUser)
        given(userRepository.save(existingUser)).willReturn(existingUser)

        val result = classUnderTest.putUserFromJwt(oidcUser)

        assertSame(existingUser, result)
        verify(userRepository, times(1)).findByOidcSub(OIDC_SUB)
        verify(userRepository, times(0)).findByEmail(any())
        verify(userFactory, times(0)).createOidcUser(any(), any(), any())
    }

    @Test
    fun `maps existing user by email when oidcSub not yet linked`() {
        val oidcUser = mockOidcUser(mockPreferredUsername = false)
        val existingUserWithoutSub = createTestUser().apply { oidcSub = null }

        given(userRepository.findByOidcSub(OIDC_SUB)).willReturn(null)
        given(userRepository.findByEmail(EXAMPLE_EMAIL)).willReturn(existingUserWithoutSub)
        given(userRepository.save(existingUserWithoutSub)).willReturn(existingUserWithoutSub)

        val result = classUnderTest.putUserFromJwt(oidcUser)

        assertSame(existingUserWithoutSub, result)
        assertEquals(OIDC_SUB, existingUserWithoutSub.oidcSub)
        verify(userRepository, times(1)).findByOidcSub(OIDC_SUB)
        verify(userRepository, times(1)).findByEmail(EXAMPLE_EMAIL)
        verify(userFactory, times(0)).createOidcUser(any(), any(), any())
    }

    @Test
    fun `creates new user when no user exists for oidcSub or email`() {
        val oidcUser = mockOidcUser(email = NON_EXISTENT_EMAIL)

        given(userRepository.findByOidcSub(OIDC_SUB)).willReturn(null)
        given(userRepository.findByEmail(NON_EXISTENT_EMAIL)).willReturn(null)

        val createdUser = createTestUser()
        given(
            userFactory.createOidcUser(
                email = NON_EXISTENT_EMAIL,
                sub = OIDC_SUB,
                name = EXAMPLE_USERNAME,
            ),
        ).willReturn(createdUser)
        given(userRepository.save(createdUser)).willReturn(createdUser)

        val result = classUnderTest.putUserFromJwt(oidcUser)

        assertSame(createdUser, result)
        verify(userRepository, times(1)).findByOidcSub(OIDC_SUB)
        verify(userRepository, times(1)).findByEmail(NON_EXISTENT_EMAIL)
        verify(userFactory, times(1)).createOidcUser(
            email = NON_EXISTENT_EMAIL,
            sub = OIDC_SUB,
            name = EXAMPLE_USERNAME,
        )
        verify(userRepository, times(1)).save(createdUser)
    }
}
