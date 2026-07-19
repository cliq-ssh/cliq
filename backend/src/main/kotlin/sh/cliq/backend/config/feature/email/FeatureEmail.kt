package sh.cliq.backend.config.feature.email

import org.springframework.boot.autoconfigure.condition.ConditionalOnBooleanProperty
import sh.cliq.backend.config.feature.FEATURE_EMAIL_PROPERTY_NAME

@ConditionalOnBooleanProperty(FEATURE_EMAIL_PROPERTY_NAME)
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class FeatureEmail
