package sh.cliq.backend.unit.user.service

import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.Mock
import org.mockito.junit.jupiter.MockitoExtension
import org.mockito.kotlin.any
import org.mockito.kotlin.verify
import org.mockito.kotlin.whenever
import org.springframework.context.MessageSource
import org.springframework.mail.MailException
import org.springframework.mail.MailSendException
import sh.cliq.backend.email.EmailSender
import sh.cliq.backend.exception.ExpiredKeyRotationCodeException
import sh.cliq.backend.exception.InvalidKeyRotationCodeException
import sh.cliq.backend.exception.InvalidKeyRotationParamsException
import sh.cliq.backend.session.SessionRepository
import sh.cliq.backend.user.User
import sh.cliq.backend.user.UserRepository
import sh.cliq.backend.user.service.KeyRotationService
import sh.cliq.backend.utils.TokenGenerator
import java.time.Clock
import java.time.Instant
import java.time.OffsetDateTime
import java.time.ZoneId
import java.util.Locale
import kotlin.test.assertEquals
import kotlin.test.assertNotNull

@ExtendWith(MockitoExtension::class)
class KeyRotationServiceTests {
    @Mock
    private lateinit var userRepository: UserRepository

    @Mock
    private lateinit var sessionRepository: SessionRepository

    @Mock
    private lateinit var tokenGenerator: TokenGenerator

    @Mock
    private lateinit var emailSender: EmailSender

    @Mock
    private lateinit var messageSource: MessageSource

    private lateinit var clock: Clock
    private lateinit var keyRotationService: KeyRotationService

    private val testUser = User(
        email = "test@example.com",
        name = "Test User",
        createdAt = OffsetDateTime.now(),
        updatedAt = OffsetDateTime.now(),
        id = 1L,
        dataEncryptionKey = "old-key",
        srpSalt = "old-salt",
        srpVerifier = "old-verifier",
        emailVerifiedAt = OffsetDateTime.now(),
    )

    @BeforeEach
    fun setUp() {
        clock = Clock.fixed(Instant.parse("2026-03-26T10:00:00Z"), ZoneId.systemDefault())
        keyRotationService = KeyRotationService(
            userRepository,
            clock,
            tokenGenerator,
            emailSender,
            messageSource,
            sessionRepository,
        )
    }

    @Test
    fun `sendKeyRotationEmail should generate code and send email`() {
        // Arrange
        val generatedCode = "ABCD1234"
        whenever(tokenGenerator.generateKeyRotationToken()).thenReturn(generatedCode)
        whenever(messageSource.getMessage("email.key_rotation.subject", null, Locale.ENGLISH))
            .thenReturn("Key Rotation Code")

        // Act
        keyRotationService.sendKeyRotationEmail(testUser)

        // Assert
        verify(emailSender).sendEmail(
            to = testUser.email,
            subject = "Key Rotation Code",
            context = mapOf("name" to testUser.name, "rotationCode" to generatedCode),
            locale = Locale.ENGLISH,
            templateName = "keyRotationMail",
        )

        // Verify the user was updated with the code
        assertEquals(generatedCode, testUser.keyRotationToken)
        assertNotNull(testUser.keyRotationSentAt)
    }

    @Test
    fun `sendKeyRotationEmail should handle email failures`() {
        // Arrange
        val generatedCode = "ABCD1234"
        whenever(tokenGenerator.generateKeyRotationToken()).thenReturn(generatedCode)
        whenever(messageSource.getMessage("email.key_rotation.subject", null, Locale.ENGLISH))
            .thenReturn("Key Rotation Code")
        whenever(emailSender.sendEmail(any(), any(), any(), any(), any()))
            .thenThrow(MailSendException("Email failed"))

        // Act & Assert
        val emailException = assertThrows<MailException> {
            keyRotationService.sendKeyRotationEmail(testUser)
        }
        assertEquals(
            "Email failed",
            emailException.message,
        )

        // Verify the reset timestamp was cleared
        assertEquals(null, testUser.keyRotationSentAt)
    }

    @Test
    fun `verifyKeyRotationCode should validate code update keys`() {
        // Arrange
        val code = "ABCD1234"
        val newDataEncryptionKey = "new-key"
        val newSrpSalt = "new-salt"
        val newSrpVerifier = "new-verifier"

        testUser.keyRotationToken = code
        testUser.keyRotationSentAt = OffsetDateTime.now(clock)

        // Act
        keyRotationService.verifyKeyRotationCode(
            testUser,
            code,
            newDataEncryptionKey,
            newSrpSalt,
            newSrpVerifier,
        )

        // Assert
        assertEquals(newDataEncryptionKey, testUser.dataEncryptionKey)
        assertEquals(newSrpSalt, testUser.srpSalt)
        assertEquals(newSrpVerifier, testUser.srpVerifier)
        assertEquals(null, testUser.keyRotationToken)
        verify(userRepository).save(testUser)
        verify(sessionRepository).deleteAllByUserId(1L)
    }

    @Test
    fun `verifyKeyRotationCode should throw error for invalid code`() {
        // Arrange
        testUser.keyRotationToken = "CORRECT_CODE"
        testUser.keyRotationSentAt = OffsetDateTime.now(clock)

        // Act & Assert
        assertThrows<InvalidKeyRotationCodeException> {
            keyRotationService.verifyKeyRotationCode(
                testUser,
                "WRONG_CODE",
                "new-key",
                "new-salt",
                "new-verifier",
            )
        }
    }

    @Test
    fun `verifyKeyRotationCode should throw error for expired code`() {
        // Arrange
        testUser.keyRotationToken = "ABCD1234"
        testUser.keyRotationSentAt = OffsetDateTime.now(clock).minusMinutes(31)

        // Act & Assert
        assertThrows<ExpiredKeyRotationCodeException> {
            keyRotationService.verifyKeyRotationCode(
                testUser,
                "ABCD1234",
                "new-key",
                "new-salt",
                "new-verifier",
            )
        }
    }

    @Test
    fun `verifyKeyRotationCode for OIDC user should not require SRP data`() {
        // Arrange
        val oidcUser = User(
            email = "oidc@example.com",
            name = "OIDC User",
            createdAt = OffsetDateTime.now(clock),
            updatedAt = OffsetDateTime.now(clock),
            id = 2L,
            oidcSub = "oidc-sub-123",
            dataEncryptionKey = "old-key",
            srpSalt = "old-salt",
            srpVerifier = "old-verifier",
            emailVerifiedAt = OffsetDateTime.now(clock),
        )
        oidcUser.keyRotationToken = "ABCD1234"
        oidcUser.keyRotationSentAt = OffsetDateTime.now(clock)

        // Act
        keyRotationService.verifyKeyRotationCode(
            oidcUser,
            "ABCD1234",
            "new-key",
            null,
            null,
        )

        // Assert
        assertEquals("new-key", oidcUser.dataEncryptionKey)
        assertEquals("old-salt", oidcUser.srpSalt)
        assertEquals("old-verifier", oidcUser.srpVerifier)
        verify(sessionRepository).deleteAllByUserId(2L)
    }

    @Test
    fun `verifyKeyRotationCode for non OIDC user should require SRP data`() {
        // Arrange
        testUser.keyRotationToken = "ABCD1234"
        testUser.keyRotationSentAt = OffsetDateTime.now(clock)

        // Act & Assert
        assertThrows<InvalidKeyRotationParamsException> {
            keyRotationService.verifyKeyRotationCode(
                testUser,
                "ABCD1234",
                "new-key",
                null,
                null,
            )
        }
    }
}
