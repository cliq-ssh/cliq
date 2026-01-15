package app.cliq.backend.utils

import org.springframework.core.env.Environment
import org.springframework.stereotype.Service

@Service
class FeatureUtils(
    private val environment: Environment,
) {
    fun isProfileActive(profile: String): Boolean = environment.activeProfiles.contains(profile)
}
