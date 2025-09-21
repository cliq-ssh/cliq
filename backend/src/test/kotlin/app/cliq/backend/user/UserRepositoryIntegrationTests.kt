package app.cliq.backend.user

import app.cliq.backend.shared.SnowflakeGenerator
import jakarta.persistence.EntityManager
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.test.context.ActiveProfiles
import org.springframework.transaction.annotation.Transactional
import java.time.OffsetDateTime
import java.util.Locale

@SpringBootTest
@Transactional
@ActiveProfiles("test")
class UserRepositoryIntegrationTests(
    @Autowired
    private val entityManager: EntityManager,
    @Autowired
    private val userRepository: UserRepository,
    @Autowired
    private val snowflakeGenerator: SnowflakeGenerator,
) {
    @BeforeEach
    fun setUp() {
        userRepository.deleteAll()
        entityManager.flush()
        entityManager.clear()
    }

    private fun createUser(
        email: String,
        name: String = "Test User",
        emailVerifiedAt: OffsetDateTime? = null,
        emailVerificationSentAt: OffsetDateTime = OffsetDateTime.now(),
        createdAt: OffsetDateTime = OffsetDateTime.now(),
        updatedAt: OffsetDateTime = OffsetDateTime.now(),
    ): User =
        User(
            id = snowflakeGenerator.nextId().getOrThrow(),
            email = email,
            name = name,
            locale = Locale.ENGLISH.toLanguageTag(),
            password = "hashed_password",
            resetToken = null,
            resetSentAt = null,
            emailVerifiedAt = emailVerifiedAt,
            emailVerificationToken =
                if (emailVerifiedAt ==
                    null
                ) {
                    "verification_token_${email.substringBefore('@')}"
                } else {
                    null
                },
            emailVerificationSentAt = emailVerificationSentAt,
            createdAt = createdAt,
            updatedAt = updatedAt,
        )

    @Test
    fun `deleteUnverifiedUsersOlderThan should delete old unverified users`() {
        // Given
        val cutoffTime = OffsetDateTime.now()
        val oldUser =
            createUser(
                email = "old@example.com",
                emailVerificationSentAt = cutoffTime.minusHours(2),
                createdAt = cutoffTime.minusHours(2),
                updatedAt = cutoffTime.minusHours(2),
            )
        val recentUser =
            createUser(
                email = "recent@example.com",
                emailVerificationSentAt = cutoffTime.plusHours(1),
                createdAt = cutoffTime.plusHours(1),
                updatedAt = cutoffTime.plusHours(1),
            )

        entityManager.persist(oldUser)
        entityManager.persist(recentUser)
        entityManager.flush()

        // When
        val deletedCount = userRepository.deleteUnverifiedUsersOlderThan(cutoffTime)

        // Then
        assertThat(deletedCount).isEqualTo(1)
        assertThat(userRepository.findAll()).hasSize(1)
        assertThat(userRepository.findAll().first().email).isEqualTo("recent@example.com")
    }

    @Test
    fun `deleteUnverifiedUsersOlderThan should not delete verified users`() {
        // Given
        val cutoffTime = OffsetDateTime.now()
        val verifiedUser =
            createUser(
                email = "verified@example.com",
                emailVerifiedAt = cutoffTime.minusHours(1),
                emailVerificationSentAt = cutoffTime.minusHours(2),
                createdAt = cutoffTime.minusHours(2),
                updatedAt = cutoffTime.minusHours(1),
            )

        entityManager.persist(verifiedUser)
        entityManager.flush()

        // When
        val deletedCount = userRepository.deleteUnverifiedUsersOlderThan(cutoffTime)

        // Then
        assertThat(deletedCount).isEqualTo(0)
        assertThat(userRepository.findAll()).hasSize(1)
    }

    @Test
    fun `deleteUnverifiedUsersOlderThan should return zero when no users match criteria`() {
        // Given
        val cutoffTime = OffsetDateTime.now()

        // When
        val deletedCount = userRepository.deleteUnverifiedUsersOlderThan(cutoffTime)

        // Then
        assertThat(deletedCount).isEqualTo(0)
    }

    @Test
    fun `deleteUnverifiedUsersOlderThan should only delete old unverified users`() {
        // Given
        val cutoffTime = OffsetDateTime.now()
        val users =
            listOf(
                createUser(
                    email = "old1@example.com",
                    emailVerificationSentAt = cutoffTime.minusHours(3),
                    createdAt = cutoffTime.minusHours(3),
                    updatedAt = cutoffTime.minusHours(3),
                ),
                createUser(
                    email = "old2@example.com",
                    emailVerificationSentAt = cutoffTime.minusHours(1),
                    createdAt = cutoffTime.minusHours(1),
                    updatedAt = cutoffTime.minusHours(1),
                ),
                createUser(
                    email = "recent@example.com",
                    emailVerificationSentAt = cutoffTime.plusHours(1),
                    createdAt = cutoffTime.plusHours(1),
                    updatedAt = cutoffTime.plusHours(1),
                ),
            )

        users.forEach {
            entityManager.persist(it)
        }
        entityManager.flush()

        // When
        val deletedCount = userRepository.deleteUnverifiedUsersOlderThan(cutoffTime)

        // Then
        assertThat(deletedCount).isEqualTo(2)
        assertThat(userRepository.findAll()).hasSize(1)
    }
}
