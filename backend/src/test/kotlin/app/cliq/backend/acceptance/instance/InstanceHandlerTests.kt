package app.cliq.backend.acceptance.instance

import app.cliq.backend.acceptance.AcceptanceTest
import app.cliq.backend.acceptance.AcceptanceTester
import app.cliq.backend.instance.Instance
import app.cliq.backend.instance.InstanceHandler
import app.cliq.backend.instance.InstanceRepository
import jakarta.persistence.EntityManager
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.getBean
import org.springframework.context.ApplicationContext
import org.springframework.transaction.PlatformTransactionManager
import java.time.Clock
import java.time.OffsetDateTime
import kotlin.test.assertEquals
import kotlin.test.assertTrue

@AcceptanceTest
class InstanceHandlerTests(
    @Autowired
    private val instanceRepository: InstanceRepository,
    @Autowired
    private val applicationContext: ApplicationContext,
) : AcceptanceTester() {
    @Test
    fun `initialize should register with smallest available ID when no instances exist`(
        @Autowired instanceHandler: InstanceHandler,
    ) {
        val nodeId = instanceHandler.getCurrentNodeId()

        assertEquals(0U, nodeId)

        val instances = instanceRepository.findAll()
        assertEquals(1, instances.size)
    }

    @Test
    fun `should use next available ID when some IDs are occupied`() {
        // Keep in mind that an instance with id 0 will be autowired
        val now = OffsetDateTime.now()
        instanceRepository.save(Instance(nodeId = 1U, createdAt = now, updatedAt = now))
        instanceRepository.save(Instance(nodeId = 2U, createdAt = now, updatedAt = now))

        val newHandler = createNewInstanceHandler()
        newHandler.initialize()

        assertEquals(3U, newHandler.getCurrentNodeId())

        val instances = instanceRepository.findAll()
        assertEquals(4, instances.size)
        assertTrue(instances.any { it.nodeId.toUInt() == 3U })
    }

    @Test
    fun `initialize should reuse existing inactive instance`() {
        val now = OffsetDateTime.now()
        val oldInstance =
            Instance(
                nodeId = 1U,
                createdAt = now.minusDays(1),
                updatedAt = now.minusDays(1),
            )
        instanceRepository.save(oldInstance)

        val newHandler = createNewInstanceHandler()
        newHandler.initialize()

        val instances = instanceRepository.findAll()
        assertEquals(2, instances.size)
        assertEquals(0U, instances[0].nodeId)
        assertEquals(1U, instances[1].nodeId)
    }

    private fun createNewInstanceHandler(): InstanceHandler =
        InstanceHandler(
            instanceRepository,
            Clock.systemDefaultZone(),
            applicationContext.getBean<PlatformTransactionManager>(),
            applicationContext.getBean<EntityManager>(),
        )
}
