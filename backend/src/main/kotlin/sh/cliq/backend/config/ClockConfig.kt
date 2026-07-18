package sh.cliq.backend.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import java.time.Clock

@Configuration
class ClockConfig {
    @Bean
    fun getSystemClock(): Clock = Clock.systemDefaultZone()
}
