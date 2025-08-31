package app.cliq.backend.unit.service

import app.cliq.backend.api.instance.InstanceHandler
import app.cliq.backend.service.MAX_NODE_ID
import app.cliq.backend.service.MAX_SEQUENCE
import app.cliq.backend.service.NODE_ID_BITS
import app.cliq.backend.service.SEQUENCE_BITS
import app.cliq.backend.service.SNOWFLAKE_EPOCH
import app.cliq.backend.service.SnowflakeGenerator
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.extension.ExtendWith
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.junit.jupiter.MockitoExtension
import org.springframework.test.util.ReflectionTestUtils
import java.time.Clock
import java.time.Instant
import java.time.ZoneId
import java.util.concurrent.CompletableFuture
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.Executors
import java.util.concurrent.atomic.AtomicLong
import kotlin.test.assertEquals
import kotlin.test.assertTrue

@ExtendWith(MockitoExtension::class)
class SnowflakeGeneratorTests {
    @Mock
    private lateinit var instanceHandler: InstanceHandler

    private lateinit var snowflakeGenerator: SnowflakeGenerator

    @BeforeEach
    fun setUp() {
        snowflakeGenerator = SnowflakeGenerator(instanceHandler, Clock.systemDefaultZone())
        Mockito.`when`(instanceHandler.getCurrentNodeId()).thenReturn(0U)
    }

    @Test
    fun `should be able to generate random ids`() {
        Mockito.`when`(instanceHandler.getCurrentNodeId()).thenReturn(0U)

        val ids = mutableSetOf<Long>()
        repeat(1000) {
            val result = snowflakeGenerator.nextId()
            assert(result.isSuccess)
            val id = result.getOrThrow()
            assert(id > 0)
            ids.add(id)
        }

        assert(ids.size == 1000)
    }

    @Test
    fun `should correctly encode node ID in generated IDs`() {
        val nodeId: UShort = 42u
        Mockito.`when`(instanceHandler.getCurrentNodeId()).thenReturn(nodeId)

        val id = snowflakeGenerator.nextId().getOrThrow()

        // Extract node ID (bits 12-21)
        val extractedNodeId = (id shr SEQUENCE_BITS) and MAX_NODE_ID
        assertEquals(nodeId.toLong(), extractedNodeId)
    }

    @Test
    fun `should correctly encode timestamp in generated IDs`() {
        // Get current timestamp
        val currentTime = System.currentTimeMillis() - SNOWFLAKE_EPOCH

        val id = snowflakeGenerator.nextId().getOrThrow()

        // Extract timestamp (bits 22-63)
        val extractedTimestamp = id shr (NODE_ID_BITS + SEQUENCE_BITS)

        // Timestamp should be very close to current time
        assertTrue(extractedTimestamp >= currentTime - 10)
        assertTrue(extractedTimestamp <= currentTime + 10)
    }

    @Test
    fun `should correctly encode sequence in generated IDs`() {
        val clock = Clock.fixed(Instant.now(), ZoneId.of("UTC"))
        val snowflakeGenerator = SnowflakeGenerator(instanceHandler, clock)
        // Reset sequence to ensure it starts at 0
        ReflectionTestUtils.setField(snowflakeGenerator, "sequence", AtomicLong(0))

        val id = snowflakeGenerator.nextId().getOrThrow()
        val id2 = snowflakeGenerator.nextId().getOrThrow()

        // Extract sequence (bits 0-11)
        val extractedSequence = id and MAX_SEQUENCE
        assertEquals(0L, extractedSequence)

        // Generate another ID in the same millisecond
        val extractedSequence2 = id2 and MAX_SEQUENCE
        assertEquals(1L, extractedSequence2)
    }

    @Test
    fun `should generate monotonically increasing IDs`() {
        val id1 = snowflakeGenerator.nextId().getOrThrow()
        val id2 = snowflakeGenerator.nextId().getOrThrow()
        val id3 = snowflakeGenerator.nextId().getOrThrow()

        assertTrue(id2 > id1)
        assertTrue(id3 > id2)
    }

    @Test
    fun `should use different node IDs correctly`() {
        val nodeId1: UShort = 5U
        val nodeId2: UShort = 10U

        Mockito.`when`(instanceHandler.getCurrentNodeId()).thenReturn(nodeId1)
        val id1 = snowflakeGenerator.nextId().getOrThrow()

        Mockito.`when`(instanceHandler.getCurrentNodeId()).thenReturn(nodeId2)
        val id2 = snowflakeGenerator.nextId().getOrThrow()

        val extractedNodeId1 = (id1 shr SEQUENCE_BITS) and MAX_NODE_ID
        val extractedNodeId2 = (id2 shr SEQUENCE_BITS) and MAX_NODE_ID

        assertEquals(nodeId1.toLong(), extractedNodeId1)
        assertEquals(nodeId2.toLong(), extractedNodeId2)
    }

    @Test
    fun `should generate unique IDs under concurrent access`() {
        val threads = 10
        val idsPerThread = 100
        val allIds = ConcurrentHashMap.newKeySet<Long>()
        val futures = ArrayList<CompletableFuture<Void>>()
        val executor = Executors.newFixedThreadPool(threads)

        repeat(threads) {
            futures.add(
                CompletableFuture.runAsync({
                    repeat(idsPerThread) {
                        val id = snowflakeGenerator.nextId().getOrThrow()
                        if (allIds.contains(id)) {
                            throw IllegalStateException("Duplicate ID generated: $id")
                        }

                        allIds.add(id)
                    }
                }, executor),
            )
        }

        CompletableFuture.allOf(*futures.toTypedArray()).join()

        assertEquals(threads * idsPerThread, allIds.size)
    }
}
