package app.cliq.backend

import app.cliq.backend.config.EmailProperties
import app.cliq.backend.config.properties.InfoProperties
import app.cliq.backend.config.properties.JwtProperties
import app.cliq.backend.config.oidc.OidcProperties
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationPropertiesScan
import org.springframework.boot.runApplication
import org.springframework.scheduling.annotation.EnableAsync
import org.springframework.scheduling.annotation.EnableScheduling

@SpringBootApplication
@ConfigurationPropertiesScan(
    basePackageClasses = [
        InfoProperties::class,
        EmailProperties::class,
        OidcProperties::class,
        JwtProperties::class
    ],
)
@EnableAsync
@EnableScheduling
class BackendApplication

fun main(args: Array<String>) {
    runApplication<BackendApplication>(*args)
}
