package sh.cliq.backend.vault.security

import org.springframework.stereotype.Component
import sh.cliq.backend.user.User
import sh.cliq.backend.vault.VaultRepository
import java.util.UUID

@Component
class VaultAuthorization(private val repository: VaultRepository) {
    fun canUpdate(id: UUID, user: User): Boolean {
        val vault = repository.findById(id)

        return vault.isEmpty || vault.get().user.id == user.id
    }
}
