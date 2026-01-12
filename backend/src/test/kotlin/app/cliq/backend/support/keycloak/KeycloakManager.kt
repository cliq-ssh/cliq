package app.cliq.backend.support.keycloak

import org.keycloak.admin.client.CreatedResponseUtil
import org.keycloak.admin.client.Keycloak
import org.keycloak.admin.client.resource.RealmResource
import org.keycloak.representations.idm.CredentialRepresentation
import org.keycloak.representations.idm.UserRepresentation
import org.springframework.boot.test.context.TestComponent

@TestComponent
class KeycloakManager(
    private val keycloakProperties: KeycloakProperties,
    private val keycloak: Keycloak,
) {
    fun createUser(
        username: String,
        password: String,
    ) {
        val user = UserRepresentation()
        user.username = username
        user.isEnabled = true

        val response = getRealm().users().create(user)

        val userId = CreatedResponseUtil.getCreatedId(response)

        val credentials = CredentialRepresentation()
        credentials.type = CredentialRepresentation.PASSWORD
        credentials.value = password
        credentials.isTemporary = false

        getRealm().users().get(userId).resetPassword(credentials)
    }

    fun deleteAllUsers() {
        getRealm().users().list().forEach { user ->
            getRealm().users().delete(user.id)
        }
    }

    private fun getRealm(): RealmResource = keycloak.realm(keycloakProperties.realm)
}
