package app.cliq.backend.shared

import app.cliq.backend.instance.InstanceHandler
import org.springframework.stereotype.Service
import java.time.Clock
import kotlin.concurrent.atomics.AtomicLong
import kotlin.concurrent.atomics.ExperimentalAtomicApi

const val SNOWFLAKE_EPOCH: Long = 1_705_247_483_000L

const val NODE_ID_BITS: Int = 10
const val SEQUENCE_BITS: Int = 12

// const val TIMESTAMP_SHIFT: Int = NODE_ID_BITS + SEQUENCE_BITS -> Not used at the moment

const val MAX_NODE_ID: Long = (1L shl NODE_ID_BITS) - 1

const val MAX_SEQUENCE: Long = (1L shl SEQUENCE_BITS) - 1

@OptIn(ExperimentalAtomicApi::class)
@Service
class SnowflakeGenerator(
    private val instanceHandler: InstanceHandler,
    private val clock: Clock,
) {
    private val lastTimestamp: AtomicLong = AtomicLong(0)
    private val sequence: AtomicLong = AtomicLong(0)

    fun nextId(): Result<Long> {
        synchronized(this) {
            var currentTimestamp = getTimestamp()
            val lastTimestamp = lastTimestamp.load()

            if (currentTimestamp < lastTimestamp) {
                return Result.failure(
                    IllegalStateException(
                        "Clock moved backwards. Refusing to generate id for ${lastTimestamp - currentTimestamp} milliseconds",
                    ),
                )
            }

            var sequence = sequence.load()
            if (currentTimestamp == lastTimestamp) {
                sequence = (sequence + 1) and MAX_SEQUENCE
                if (sequence == 0L) {
                    currentTimestamp = waitForNextMillis(lastTimestamp)
                }
            } else {
                sequence = 0L
            }

            this.lastTimestamp.store(currentTimestamp)
            this.sequence.store(sequence)

            val nodeId = instanceHandler.getCurrentNodeId().toLong()

            val id = ((currentTimestamp shl (NODE_ID_BITS + SEQUENCE_BITS)) or (nodeId shl SEQUENCE_BITS) or sequence)

            return Result.success(id)
        }
    }

    private fun waitForNextMillis(lastTimestamp: Long): Long {
        var currentTimestamp = getTimestamp()
        while (currentTimestamp <= lastTimestamp) {
            currentTimestamp = getTimestamp()
        }

        return currentTimestamp
    }

    private fun getTimestamp(): Long = clock.millis() - SNOWFLAKE_EPOCH
}
