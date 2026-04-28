package app.cliq.backend.config.feature.oidc

import app.cliq.backend.config.feature.FEATURE_OIDC_PROPERTY_NAME
import org.springframework.boot.autoconfigure.condition.ConditionalOnBooleanProperty

@ConditionalOnBooleanProperty(FEATURE_OIDC_PROPERTY_NAME)
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class FeatureOidc
