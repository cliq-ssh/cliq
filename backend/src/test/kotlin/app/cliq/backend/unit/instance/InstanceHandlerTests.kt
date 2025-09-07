package app.cliq.backend.unit.instance

import app.cliq.backend.instance.Instance
import app.cliq.backend.instance.InstanceHandler
import app.cliq.backend.instance.InstanceRepository
import app.cliq.backend.shared.MAX_NODE_ID
import jakarta.persistence.EntityManager
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.junit.jupiter.MockitoExtension
import org.mockito.kotlin.any
import org.springframework.test.util.ReflectionTestUtils
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.TransactionStatus
import java.time.Clock
import java.time.Instant
import java.time.OffsetDateTime
import java.time.ZoneId
import kotlin.test.assertFailsWith
import kotlin.test.assertTrue

@ExtendWith(MockitoExtension::class)
class InstanceHandlerTests {
    @Mock
    private lateinit var instanceRepository: InstanceRepository

    @Mock
    private lateinit var entityManager: EntityManager

    @Mock
    private lateinit var transactionManager: PlatformTransactionManager

    private lateinit var instanceHandler: InstanceHandler

    @BeforeEach
    fun setUp() {
        val clock = Clock.fixed(Instant.ofEpochMilli(0), ZoneId.of("UTC"))
        instanceHandler = InstanceHandler(instanceRepository, clock, transactionManager, entityManager)

        instanceHandler = InstanceHandler(instanceRepository, clock, transactionManager, entityManager)
    }

    @Test
    fun `initialize should throw exception when no node IDs available`() {
        // Non-dependent mocks
        val mockTransaction = Mockito.mock(TransactionStatus::class.java)
        Mockito.`when`(transactionManager.getTransaction(any())).thenReturn(mockTransaction)

        // Create max instances
        val maxInstances =
            (0..MAX_NODE_ID).map {
                Instance(
                    nodeId = it.toUShort(),
                    createdAt = OffsetDateTime.now(),
                    updatedAt = OffsetDateTime.now(),
                )
            }

        // Mocks
        Mockito.`when`(instanceRepository.findAllAndLock()).thenReturn(maxInstances)
        Mockito.`when`(instanceRepository.getAllOccupied(any())).thenReturn(maxInstances)

        // Act & Assert
        assertFailsWith<IllegalStateException> {
            instanceHandler.initialize()
        }
    }

    @Test
    fun `sendHeartbeat should update instance timestamp`() {
        // Arrange
        val now = OffsetDateTime.now()
        val instance =
            Instance(
                nodeId = 0U,
                createdAt = now,
                updatedAt = now,
            )

        // Set the currentInstance field using reflection
        ReflectionTestUtils.setField(instanceHandler, "currentInstance", instance)

        // Act
        instanceHandler.sendHeartbeat()

        // Assert
        Mockito.verify(entityManager).merge<Instance>(any())
        assertTrue {
            instanceHandler.getInstance().updatedAt > now
            instanceHandler.getInstance().createdAt == now
        }
    }

    @Test
    fun `getCurrentNodeId should throw exception when not initialized`() {
        // Act & Assert
        assertFailsWith<IllegalStateException> {
            instanceHandler.getCurrentNodeId()
        }
    }
}
