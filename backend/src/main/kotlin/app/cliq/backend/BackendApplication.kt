package app.cliq.backend

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.modulith.Modulithic
import org.springframework.scheduling.annotation.EnableAsync
import org.springframework.scheduling.annotation.EnableScheduling

@SpringBootApplication
@EnableAsync
@EnableScheduling
@Modulithic(
    sharedModules = [
        "app.cliq.backend.config",
        "app.cliq.backend.shared",
        "app.cliq.backend.instance",
        "app.cliq.backend.error",
        "app.cliq.backend.exception",
    ]
)
class BackendApplication

fun main(args: Array<String>) {
    runApplication<BackendApplication>(*args)
}
