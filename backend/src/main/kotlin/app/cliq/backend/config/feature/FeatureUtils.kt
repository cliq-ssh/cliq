package app.cliq.backend.config.feature

import org.springframework.core.env.Environment
import org.springframework.core.env.getProperty
import org.springframework.stereotype.Service

@Service
class FeatureUtils(private val environment: Environment) {
    fun isFeatureActive(feature: Features): Boolean = isPropertyTrue(feature.property)

    private fun isPropertyTrue(property: String): Boolean = environment.getProperty<Boolean>(property, false)
}
