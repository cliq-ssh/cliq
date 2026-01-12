package app.cliq.backend.acceptance

import app.cliq.backend.support.DatabaseCleanupService
import app.cliq.backend.support.keycloak.KeycloakManager
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeAll
import org.springframework.beans.factory.annotation.Autowired

@AcceptanceTest
annotation class OidcAcceptanceTest

@OidcAcceptanceTest
abstract class OidcAcceptanceTester {
    @BeforeAll
    @AfterEach
    fun clearDatabase(
        @Autowired cleaner: DatabaseCleanupService,
    ) {
        cleaner.truncate()
    }

    @BeforeAll
    @AfterEach
    fun clearKeycloak(
        @Autowired keycloakManager: KeycloakManager,
    ) {
        keycloakManager.deleteAllUsers()
    }
}
