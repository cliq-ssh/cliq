package app.cliq.backend.config.feature.email

import app.cliq.backend.config.feature.FEATURE_EMAIL_PROPERTY_NAME
import org.springframework.boot.autoconfigure.condition.ConditionalOnBooleanProperty

@ConditionalOnBooleanProperty(FEATURE_EMAIL_PROPERTY_NAME)
@Target(AnnotationTarget.CLASS, AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.RUNTIME)
annotation class FeatureEmail
