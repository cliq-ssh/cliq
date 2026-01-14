package app.cliq.backend.acceptance

import app.cliq.backend.constants.Features
import app.cliq.backend.support.DatabaseCleanupService
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.BeforeAll
import org.junit.jupiter.api.Tag
import org.junit.jupiter.api.TestInstance
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.context.properties.ConfigurationPropertiesScan
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc
import org.springframework.context.annotation.ComponentScan
import org.springframework.test.context.ActiveProfiles

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ConfigurationPropertiesScan(basePackages = ["app.cliq.backend.support"])
@ComponentScan(basePackages = ["app.cliq.backend.support"])
@AutoConfigureMockMvc
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
@ActiveProfiles(Features.TEST)
@Tag("acceptance")
annotation class AcceptanceTest

@AcceptanceTest
abstract class AcceptanceTester {
    @BeforeAll
    @AfterEach
    fun clearDatabase(
        @Autowired cleaner: DatabaseCleanupService,
    ) {
        cleaner.truncate()
    }
}
