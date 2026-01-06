package app.cliq.backend.acceptance

import app.cliq.backend.support.DatabaseCleanupService
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Tag
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc
import org.springframework.context.annotation.ComponentScan
import org.springframework.test.context.ActiveProfiles

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureMockMvc
@ComponentScan(basePackages = ["app.cliq.backend.support"])
@ActiveProfiles("test")
@Tag("acceptance")
annotation class AcceptanceTest

@AcceptanceTest
abstract class AcceptanceTester {
    @AfterEach
    fun clearDatabase(
        @Autowired cleaner: DatabaseCleanupService,
    ) {
        cleaner.truncate()
    }
}
