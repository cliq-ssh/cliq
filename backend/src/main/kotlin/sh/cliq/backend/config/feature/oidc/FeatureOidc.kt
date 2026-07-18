package sh.cliq.backend.config.feature.oidc

import org.springframework.boot.autoconfigure.condition.ConditionalOnBooleanProperty
import sh.cliq.backend.config.feature.FEATURE_OIDC_PROPERTY_NAME

@ConditionalOnBooleanProperty(FEATURE_OIDC_PROPERTY_NAME)
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class FeatureOidc
