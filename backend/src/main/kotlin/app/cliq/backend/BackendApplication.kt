package app.cliq.backend

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationPropertiesScan
import org.springframework.boot.runApplication
import org.springframework.cache.annotation.EnableCaching
import org.springframework.scheduling.annotation.EnableAsync
import org.springframework.scheduling.annotation.EnableScheduling

@SpringBootApplication
@ConfigurationPropertiesScan(
    basePackages = [
        "app.cliq.backend.config",
    ],
)
@EnableAsync
@EnableScheduling
@EnableCaching
class BackendApplication

fun main(args: Array<String>) {
    runApplication<BackendApplication>(*args)
}
