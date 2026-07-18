package sh.cliq.backend.acceptance.auth.tasks

import org.assertj.core.api.Assertions
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertNotNull
import org.springframework.beans.factory.annotation.Autowired
import sh.cliq.backend.acceptance.AcceptanceTest
import sh.cliq.backend.acceptance.AcceptanceTester
import sh.cliq.backend.auth.AuthExchange
import sh.cliq.backend.auth.AuthExchangeRepository
import sh.cliq.backend.auth.factory.AuthExchangeFactory
import sh.cliq.backend.auth.tasks.AuthExchangeCleanUpTask
import sh.cliq.backend.support.UserCreationHelper
import java.time.Clock
import java.time.OffsetDateTime
import kotlin.test.assertEquals

@AcceptanceTest
class AuthExchangeCleanUpTaskTests(
    @Autowired
    private val authExchangeCleanUpTask: AuthExchangeCleanUpTask,
    @Autowired
    private val authExchangeRepository: AuthExchangeRepository,
    @Autowired
    private val authExchangeFactory: AuthExchangeFactory,
    @Autowired
    private val userCreationHelper: UserCreationHelper,
    @Autowired
    private val clock: Clock,
) : AcceptanceTester() {
    private fun createAuthExchange(expiresAt: OffsetDateTime): AuthExchange {
        val userCreationData = userCreationHelper.createRandomUser()
        val authExchange =
            authExchangeFactory.create(
                ipAddress = "127.0.0.1",
                user = userCreationData.user,
            )
        authExchange.expiresAt = expiresAt

        return authExchangeRepository.save(authExchange)
    }

    @Test
    fun `cleanUpExpiredAuthExchanges should not delete non-expired auth exchanges`() {
        // Given
        val now = OffsetDateTime.now(clock)
        val validAuthExchange = createAuthExchange(expiresAt = now.plusMinutes(5))

        // When
        authExchangeCleanUpTask.cleanUpExpiredAuthExchanges()

        // Then
        assertNotNull(authExchangeRepository.findById(validAuthExchange.id!!))
    }

    @Test
    fun `cleanUpExpiredAuthExchanges should delete multiple expired auth exchanges`() {
        // Given
        val now = OffsetDateTime.now(clock)
        createAuthExchange(expiresAt = now.minusMinutes(10))
        createAuthExchange(expiresAt = now.minusMinutes(5))
        createAuthExchange(expiresAt = now.minusSeconds(1))

        assertEquals(3, authExchangeRepository.count())

        // When
        authExchangeCleanUpTask.cleanUpExpiredAuthExchanges()

        // Then
        assertEquals(0, authExchangeRepository.count())
    }

    @Test
    fun `cleanUpExpiredAuthExchanges should handle mixed expired and non-expired auth exchanges`() {
        // Given
        val now = OffsetDateTime.now(clock)
        createAuthExchange(expiresAt = now.minusMinutes(10))
        createAuthExchange(expiresAt = now.minusMinutes(1))
        val validAuthExchange1 = createAuthExchange(expiresAt = now.plusMinutes(5))
        val validAuthExchange2 = createAuthExchange(expiresAt = now.plusHours(1))

        assertEquals(4, authExchangeRepository.count())

        // When
        authExchangeCleanUpTask.cleanUpExpiredAuthExchanges()

        // Then
        val remainingAuthExchanges = authExchangeRepository.findAll()

        assertEquals(2, remainingAuthExchanges.size)

        Assertions.assertThat(remainingAuthExchanges.map { it.id }).containsExactlyInAnyOrder(
            validAuthExchange1.id,
            validAuthExchange2.id,
        )
    }

    @Test
    fun `cleanUpExpiredAuthExchanges should handle empty repository`() {
        // Given - empty repository

        // When
        authExchangeCleanUpTask.cleanUpExpiredAuthExchanges()

        // Then
        assertEquals(0, authExchangeRepository.count())
    }

    @Test
    fun `cleanUpExpiredAuthExchanges should delete auth exchange at exact expiry time`() {
        // Given
        val now = OffsetDateTime.now(clock)
        createAuthExchange(expiresAt = now)

        assertEquals(1, authExchangeRepository.count())

        // When
        authExchangeCleanUpTask.cleanUpExpiredAuthExchanges()

        // Then - auth exchange at the exact expiry time should be deleted
        assertEquals(0, authExchangeRepository.count())
    }
}
