package app.cliq.backend.instance

import jakarta.persistence.LockModeType
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Lock
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository
import java.lang.Short
import java.time.OffsetDateTime

@Repository
interface InstanceRepository : JpaRepository<Instance, Short> {
    /**
     * Finds all instances and locks them for writing.
     * This method is used to ensure that no other transactions can modify the instances
     *
     * @throws jakarta.persistence.TransactionRequiredException if called outside a transaction.
     */
    @Lock(LockModeType.PESSIMISTIC_WRITE)
    @Query("SELECT i FROM Instance i")
    fun findAllAndLock(): List<Instance>

    @Query("SELECT i FROM Instance i WHERE i.updatedAt > :cutoffTime")
    fun getAllOccupied(
        cutoffTime: OffsetDateTime = OffsetDateTime.now().minusSeconds(INSTANCE_HEARTBEAT_TOLERANCE_SECONDS),
    ): List<Instance>
}
