package app.cliq.backend.api.instance

import app.cliq.backend.service.MAX_NODE_ID
import jakarta.annotation.PostConstruct
import jakarta.annotation.PreDestroy
import jakarta.persistence.EntityManager
import org.slf4j.LoggerFactory
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.annotation.Transactional
import org.springframework.transaction.support.DefaultTransactionDefinition
import java.time.Clock
import java.time.OffsetDateTime
import java.util.concurrent.TimeUnit

const val INSTANCE_HEARTBEAT_INTERVAL_SECONDS: Long = 10L
const val INSTANCE_HEARTBEAT_TOLERANCE_SECONDS: Long = 30L // 3 * INSTANCE_HEARTBEAT_INTERVAL_SECONDS

@Service
class InstanceHandler(
    private val instanceRepository: InstanceRepository,
    private val clock: Clock,
    private val transactionManager: PlatformTransactionManager,
    private val entityManager: EntityManager,
) {
    private val logger = LoggerFactory.getLogger(this::class.java)
    private lateinit var currentInstance: Instance

    @PostConstruct
    fun initialize() {
        val transaction = transactionManager.getTransaction(DefaultTransactionDefinition())
        try {
            val allInstances = instanceRepository.findAllAndLock()
            val activeInstances = instanceRepository.getAllOccupied()

            val occupiedIds = activeInstances.map { it.nodeId }.toSet()
            val nextId = findSmallestAvailableId(occupiedIds)

            if (nextId > MAX_NODE_ID.toUShort()) {
                logger.error("No available node IDs left")
                throw IllegalStateException("No available node IDs left")
            }

            logger.info("Initializing instance with node ID: $nextId")

            // Check if this node ID already exists but is inactive
            val existingInstance = allInstances.find { it.nodeId == nextId }

            currentInstance =
                if (existingInstance != null) {
                    // Delete inactive instances
                    existingInstance.updatedAt = OffsetDateTime.now(clock)
                    instanceRepository.save(existingInstance)
                } else {
                    // Create new instance
                    val newInstance =
                        Instance(
                            nodeId = nextId,
                            createdAt = OffsetDateTime.now(),
                            updatedAt = OffsetDateTime.now(),
                        )
                    instanceRepository.save(newInstance)
                }

            logger.info("Instance initialized with ID: ${currentInstance.nodeId}")

            // Send initial heartbeat
            sendHeartbeat()

            transactionManager.commit(transaction)
        } catch (e: Throwable) {
            transactionManager.rollback(transaction)
            throw e
        }
    }

    @Scheduled(fixedRate = INSTANCE_HEARTBEAT_INTERVAL_SECONDS, timeUnit = TimeUnit.SECONDS)
    @Transactional
    fun sendHeartbeat() {
        if (!::currentInstance.isInitialized) {
            logger.warn("Attempted to send heartbeat but instance is not initialized")
            return
        }

        currentInstance.updatedAt = OffsetDateTime.now()
        entityManager.merge(currentInstance)
        logger.debug("Heartbeat sent for instance ID: ${currentInstance.nodeId}")
    }

    @PreDestroy
    @Transactional
    fun cleanup() {
        if (::currentInstance.isInitialized) {
            // We don't delete the instance, just let it expire by not sending heartbeats
            logger.info("Instance ${currentInstance.nodeId} shutting down")
        }
    }

    private fun findSmallestAvailableId(occupiedIds: Set<UShort>): UShort {
        var candidate: UShort = 0U
        while (occupiedIds.contains(candidate)) {
            candidate++
        }

        return candidate
    }

    fun getCurrentNodeId(): UShort {
        if (!::currentInstance.isInitialized) {
            throw IllegalStateException("Instance not initialized")
        }

        return currentInstance.nodeId
    }

    fun getInstance(): Instance {
        if (!::currentInstance.isInitialized) {
            throw IllegalStateException("Instance not initialized")
        }

        return currentInstance
    }
}
