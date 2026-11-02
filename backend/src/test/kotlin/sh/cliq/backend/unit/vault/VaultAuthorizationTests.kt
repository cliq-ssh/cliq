package sh.cliq.backend.unit.vault

import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.Test
import org.mockito.kotlin.mock
import org.mockito.kotlin.whenever
import sh.cliq.backend.acceptance.AcceptanceTest
import sh.cliq.backend.acceptance.AcceptanceTester
import sh.cliq.backend.user.User
import sh.cliq.backend.vault.VaultData
import sh.cliq.backend.vault.VaultRepository
import sh.cliq.backend.vault.security.VaultAuthorization
import java.util.Optional
import java.util.UUID

@AcceptanceTest
class VaultAuthorizationTests : AcceptanceTester() {
    private val repository: VaultRepository = mock()
    private val authorization = VaultAuthorization(repository)

    @Test
    fun `allows updating a vault that does not exist`() {
        val id = UUID.randomUUID()
        val user = mock<User>()
        whenever(repository.findById(id)).thenReturn(Optional.empty())

        assertTrue(authorization.canUpdate(id, user))
    }

    @Test
    fun `allows the owner to update an existing vault`() {
        val id = UUID.randomUUID()
        val owner = mock<User>()
        val vault = mock<VaultData>()
        whenever(owner.id).thenReturn(1L)
        whenever(vault.user).thenReturn(owner)
        whenever(repository.findById(id)).thenReturn(Optional.of(vault))

        assertTrue(authorization.canUpdate(id, owner))
    }

    @Test
    fun `denies another user from updating an existing vault`() {
        val id = UUID.randomUUID()
        val owner = mock<User>()
        val otherUser = mock<User>()
        val vault = mock<VaultData>()
        whenever(owner.id).thenReturn(1L)
        whenever(otherUser.id).thenReturn(2L)
        whenever(vault.user).thenReturn(owner)
        whenever(repository.findById(id)).thenReturn(Optional.of(vault))

        assertFalse(authorization.canUpdate(id, otherUser))
    }
}
