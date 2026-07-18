package sh.cliq.backend.acceptance

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
import sh.cliq.backend.support.DatabaseCleanupService

@SpringBootTest(
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
    properties = [
        "app.rate-limits.enabled=false",
    ],
)
@ConfigurationPropertiesScan(basePackages = ["sh.cliq.backend.support"])
@ComponentScan(basePackages = ["sh.cliq.backend.support"])
@AutoConfigureMockMvc
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
@ActiveProfiles("test")
@Tag("acceptance")
annotation class AcceptanceTest

@AcceptanceTest
abstract class AcceptanceTester {
    @BeforeAll
    @AfterEach
    fun clearDatabase(@Autowired cleaner: DatabaseCleanupService) {
        cleaner.truncate()
    }
}
